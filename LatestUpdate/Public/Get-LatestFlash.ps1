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

        #region get the download link from Windows Update
        try {
            Write-Verbose -Message "Found ID: KB$($kbID)"
            Write-Verbose -Message "Reading http://www.catalog.update.microsoft.com/Search.aspx?q=KB$($kbID)."
            $kbObj = Invoke-WebRequest -Uri "http://www.catalog.update.microsoft.com/Search.aspx?q=KB$($kbID)" `
                -UseBasicParsing -ErrorAction SilentlyContinue
        }
        catch {
            # Write warnings if we can't read values
            If ($Null -eq $kbObj) { Write-Warning -Message "kbObj is Null. Unable to read KB details from the Catalog." }
            If ($Null -eq $kbObj.InputFields) { Write-Warning -Message "kbObj.InputFields is Null. Unable to read button details from the Catalog KB page." }
            Throw $_
            Break
        }
        #endregion

        #region Contruct a table with KB, Id and Update description
        Write-Verbose -Message "Contructing temporary table with KB, ID and URL."
        [regex] $rx = "<a[^>]*>([^<]+)<\/a>"
        $idTable = $kbObj.Links | Where-Object ID -match '_link' | `
            Select-Object @{n = "KB"; e = {"KB$kbID"}}, @{n = "Id"; e = {$_.id.Replace('_link', '')}}, `
        @{n = "Note"; e = {(($_.outerHTML -replace $rx, '$1').TrimStart()).TrimEnd()}}

        $output = @()
        ForEach ($idItem in $idTable) {
            try {
                Write-Verbose -Message "Checking Microsoft Update Catalog for Id: $($idItem.id)."
                $post = @{ size = 0; updateID = $idItem.id; uidInfo = $idItem.id } | ConvertTo-Json -Compress
                $postBody = @{ updateIDs = "[$post]" }
                $url = Invoke-WebRequest -Uri 'http://www.catalog.update.microsoft.com/DownloadDialog.aspx' `
                    -Method Post -Body $postBody -UseBasicParsing -ErrorAction SilentlyContinue |
                    Select-Object -ExpandProperty Content |
                    Select-String -AllMatches -Pattern "(http[s]?\://download\.windowsupdate\.com\/[^\'\""]*)" | 
                    ForEach-Object { $_.matches.value }
            }
            catch {
                Throw $_
                Write-Warning "Failed to parse Microsoft Update Catalog for Id: $($idItem.id)."
                Break
            }
            finally {
                Write-Verbose -Message "Adding $url to output."
                $newItem = New-Object PSObject
                $newItem | Add-Member -type NoteProperty -Name 'KB' -Value $idItem.KB
                $newItem | Add-Member -type NoteProperty -Name 'Arch' `
                    -Value (Get-RxString -String $idItem.Note -RegEx "\s+([a-zA-Z0-9]+)-based")
                $newItem | Add-Member -type NoteProperty -Name 'Note' -Value $idItem.Note
                $newItem | Add-Member -type NoteProperty -Name 'URL' -Value $url
                $output += $newItem
            }
        }
        #endregion
    }

    End {
        # Write the URLs list to the pipeline
        Write-Output $output
    }
}
