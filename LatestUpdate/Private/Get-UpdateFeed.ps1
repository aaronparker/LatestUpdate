Function Get-UpdateFeed {
    <#
        .SYNOPSIS
            Gets the Microsoft update RSS feed and returns the XML

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER UpdateFeed
            URI to the feed.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [String] $UpdateFeed
    )
    
    #region Find the KB Article Number
    #! Fix for Invoke-WebRequest creating BOM in XML files; Handle Temp locations on Windows, macOS / Linux
    try {
        If (Test-Path env:Temp) {
            $tempDir = $env:Temp
        }
        ElseIf (Test-Path env:TMPDIR) {
            $tempDir = $env:TMPDIR
        }
        $tempFile = Join-Path -Path $tempDir -ChildPath ([System.IO.Path]::GetRandomFileName())
        Write-Verbose -Message "Downloading feed of updates $UpdateFeed."
        Invoke-WebRequest -Uri $UpdateFeed -ContentType 'application/atom+xml; charset=utf-8' `
            -UseBasicParsing -OutFile $tempFile -ErrorAction SilentlyContinue
    }
    catch {
        Throw $_
    }
        
    # Import the XML from the feed into a variable and delete the temp file
    try {
        Write-Verbose -Message "Reading RSS XML from $tempFile."
        $feedXML = [xml] (Get-Content -Path $tempFile -ErrorAction SilentlyContinue)
    }
    catch {
        Write-Error "Failed to read XML from $tempFile."
    }
    try {
        Write-Verbose -Message "Deleting $tempFile."
        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning -Message "Failed to remove file $tempFile."
    }
    #! End fix

    # Return the XML to the pipeline
    Write-Output $feedXML
}
