Function Get-UpdateFeed {
    [OutputType([System.Xml.XmlNode])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.String] $Uri
    )
    
    # Fix for Invoke-WebRequest creating BOM in XML files; Handle Temp locations on Windows, macOS / Linux
    If (Test-Path -Path env:Temp) {
        $tempDir = $env:Temp
    }
    ElseIf (Test-Path -Path env:TMPDIR) {
        $tempDir = $env:TMPDIR
    }
    $tempFile = Join-Path -Path $tempDir -ChildPath ([System.IO.Path]::GetRandomFileName())

    try {
        $params = @{
            Uri             = $Uri
            ContentType     = 'application/atom+xml; charset=utf-8'
            UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
            UseBasicParsing = $True
            OutFile         = $tempFile
            ErrorAction     = "SilentlyContinue"
        }
        Invoke-WebRequest @params
    }
    catch [System.Net.WebException] {
        Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
    }
    catch [System.Exception] {
        Write-Warning -Message "Failed to retreive the update feed: $Uri."
        Throw $_.Exception.Message
    }
    
    # Import the XML from the feed into a variable and delete the temp file
    If (Test-Path -Path $tempFile) {
        try {
            [xml] $xml = Get-Content -Path $tempFile -Raw -ErrorAction SilentlyContinue
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to read XML from file: $tempFile."
            Throw $_.Exception.Message
        }
        try {
            Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to remove file: $tempFile."
        }
    }

    If ($Null -ne $xml) {
        Write-Output -InputObject $xml
    }
}
