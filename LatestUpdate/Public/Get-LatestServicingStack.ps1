Function Get-LatestServicingStack {
    [CmdletBinding()]
    Param()

    [String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/6ae59d69-36fc-8e4d-23dd-631d98bf74a9/atom'
    [regex] $ssu = "Servicing stack update.*"

    $tempDir = $env:TMPDIR
    $tempFile = Join-Path -Path $tempDir -ChildPath ([System.IO.Path]::GetRandomFileName())

    Invoke-WebRequest -Uri $StartKB -ContentType 'application/atom+xml; charset=utf-8' `
        -UseBasicParsing -OutFile $tempFile -ErrorAction SilentlyContinue
    $xml = [xml] (Get-Content -Path $tempFile -ErrorAction SilentlyContinue)

    $ssus = $xml.feed.entry | Where-Object { $_.title -match $ssu } | Select-Object title, id, updated

    $output = @()
    $builds = @('1607', '1703', '1709', '1803', '1809')
    [regex] $rxM = "(\d{4}-\d{2}-\d{2})"
    [regex] $rxA = "<a[^>]*>([^<]+)<\/a>"
    ForEach ($build in $builds) {
        $date = $ssus | Where-Object { $_.title -match $build } | Select-Object -ExpandProperty updated | `
            ForEach-Object { ([regex]::match($_, $rxM).Groups[1].Value) } | Sort-Object | Select-Object -Last 1

        $kbID = $ssus | Where-Object { ($_.title -match $build) -and ($_.updated -match $date ) } | Select-Object -ExpandProperty id `
            | ForEach-Object { $_.split(':') | Select-Object -Last 1 }

        ForEach ($id in $kbID) {
            $kbObj = Invoke-WebRequest -Uri "http://www.catalog.update.microsoft.com/Search.aspx?q=KB$($id)" `
                -UseBasicParsing -ErrorAction SilentlyContinue

            $idTable = $kbObj.Links | Where-Object ID -match '_link' | `
                Select-Object @{n = "KB"; e = {"KB$kbID"}}, @{n = "Id"; e = {$_.id.Replace('_link', '')}}, `
            @{n = "Note"; e = {(([regex]::match($_.outerHTML, $rxA).Groups[1].Value).TrimStart()).TrimEnd()}}

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
                        -Value ([regex]::match($idItem.Note, "\s+([a-zA-Z0-9]+)-based").Groups[1].Value)
                    $newItem | Add-Member -type NoteProperty -Name 'Build' -Value $build
                    $newItem | Add-Member -type NoteProperty -Name 'Note' -Value $idItem.Note
                    $newItem | Add-Member -type NoteProperty -Name 'URL' -Value $url
                    $output += $newItem
                }
            }
        }
    }

    Write-Output ($output | Sort-Object -Property Build -Descending | Format-Table)
}
