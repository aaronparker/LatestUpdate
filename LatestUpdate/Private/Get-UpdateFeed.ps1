Function Get-UpdateFeed {
    [OutputType([System.Xml.XmlNode])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri
    )

    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource
    
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
            OutFile         = $tempFile
            ContentType     = $resourceStrings.ContentType.atom
            UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
            UseBasicParsing = $True
            ErrorAction     = $resourceStrings.Preferences.ErrorAction
        }
        Invoke-WebRequest @params
    }
    catch [System.Net.WebException] {
        Write-Warning -Message ($($MyInvocation.MyCommand))
        Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to retreive the update feed: $Uri."
        Throw $_.Exception.Message
    }
    
    # Import the XML from the feed into a variable and delete the temp file
    If (Test-Path -Path $tempFile) {
        try {
            [xml] $xml = Get-Content -Path $tempFile -Raw -ErrorAction $resourceStrings.Preferences.ErrorAction
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to read XML from file: $tempFile."
            Throw $_.Exception.Message
        }
        try {
            Remove-Item -Path $tempFile -Force -ErrorAction $resourceStrings.Preferences.ErrorAction
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to remove file: $tempFile."
        }
    }

    If ($Null -ne $xml) {
        Write-Output -InputObject $xml
    }
}
