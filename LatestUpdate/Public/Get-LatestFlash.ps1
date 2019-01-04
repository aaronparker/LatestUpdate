Function Get-LatestFlash {
    <#
        .SYNOPSIS
            Get the latest Adobe Flash Player update for Windows.

        .DESCRIPTION

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK


        .EXAMPLE
            Get-LatestUpdate -WindowsVersion Windows7
        
            Description:
            Enumerate the latest Monthly Update for Windows 7 (and Windows 7 Embedded).
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param()

    Begin {
        [String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/6ae59d69-36fc-8e4d-23dd-631d98bf74a9/atom'
        [regex] $Flash = ".*Adobe Flash Player.*"
    }

    Process {
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
            Write-Verbose -Message "Downloading $StartKB to retrieve the list of updates."
            Invoke-WebRequest -Uri $StartKB -ContentType 'application/atom+xml; charset=utf-8' `
                -UseBasicParsing -OutFile $tempFile -ErrorAction SilentlyContinue
            Write-Verbose -Message "Read RSS feed into $tempFile."
        }
        catch {
            Throw $_
            Break
        }

        # Import the XML from the feed into a variable and delete the temp file
        try {
            $xml = [xml] (Get-Content -Path $tempFile -ErrorAction SilentlyContinue)
        }
        catch {
            Write-Error "Failed to read XML from $tempFile."
            Break
        }
        try {
            Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
        }
        catch {
            Write-Warning -Message "Failed to remove file $tempFile."
        }
        #! End fix
        
        try {
            [regex] $rxM = "(\d{4}-\d{2}-\d{2})"
            # [regex] $rxT = "(\d{2}:\d{2}:\d{2})"

            $date = $xml.feed.entry | Where-Object { $_.title -match $Flash } | Select-Object -ExpandProperty updated | `
                ForEach-Object { Get-RxString -String $_ -RegEx $rxM } | Sort-Object | Select-Object -Last 1

            $kbID = $xml.feed.entry | Where-Object { ($_.title -match $Flash) -and ($_.updated -match $date ) } | Select-Object -ExpandProperty id `
                | ForEach-Object { $_.split(':') | Select-Object -Last 1 }
        }
        catch {   
            If ($Null -eq $kbID) { Write-Warning -Message "kbID is Null. Unable to read from the KB from the JSON." }
            Break
        }
        #endregion

        # Get the download link from Windows Update
        $kbObj = Get-UpdateCatalogLink -KB $kbID
        If ($Null -ne $kbObj) {

            # Contruct a table with KB, Id and Update description
            $idTable = Get-KbUpdateArray -Links $kbObj.Links -KB $kbID

            # Process the IdTable to get a new array with KB, Architecture, Note and URL for each download
            $downloadArray = Get-UpdateDownloadArray -IdTable $idTable
        }
    }
    End {
        # Write the URLs list to the pipeline
        Write-Output $downloadArray
    }
}
