Function Get-UpdateFeed {
    <#
        .SYNOPSIS
            Returns an XML object from the specified update feed
    #>
    [OutputType([System.Xml.XmlNode])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri
    )

    # Disable the Invoke-WebRequest progress bar for faster downloads
    If ($PSBoundParameters.ContainsKey('Verbose')) {
        $ProgressPreference = "Continue"
    }
    Else {
        $ProgressPreference = "SilentlyContinue"
    }

    # Fix for Invoke-WebRequest creating BOM in XML files; Handle Temp locations on Windows, macOS / Linux
    If (Test-Path -Path env:Temp) {
        $tempDir = $env:Temp
    }
    ElseIf (Test-Path -Path env:TMPDIR) {
        $tempDir = $env:TMPDIR
    }
    $tempFile = Join-Path -Path $tempDir -ChildPath ([System.IO.Path]::GetRandomFileName())

    Write-Verbose -Message "$($MyInvocation.MyCommand): Requesting update feed at: $Uri."
    try {
        $params = @{
            Uri             = $Uri
            OutFile         = $tempFile
            ContentType     = $script:resourceStrings.ContentType.atom
            UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
            UseBasicParsing = $True
            ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
        }
        Invoke-WebRequest @params
    }
    catch [System.Net.WebException] {
        Write-Warning -Message "$($MyInvocation.MyCommand): WebException: Failed to retrieve the update feed: $Uri."
        Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to retrieve the update feed: $url."
        Throw $_.Exception.Message
    }
    
    # Import the XML from the feed into a variable and delete the temp file
    If (Test-Path -Path $tempFile) {
        try {
            [xml] $xml = Get-Content -Path $tempFile -Raw -ErrorAction $script:resourceStrings.Preferences.ErrorAction
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to read XML from file: $tempFile."
            Throw $_.Exception.Message
        }
        try {
            Remove-Item -Path $tempFile -Force -ErrorAction $script:resourceStrings.Preferences.ErrorAction
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to remove file: $tempFile."
        }
    }

    If ($Null -ne $xml) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): retrieved feed."
        Write-Output -InputObject $xml
    }
}
