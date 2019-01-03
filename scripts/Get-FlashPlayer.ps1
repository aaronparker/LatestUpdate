[String] $WindowsVersion = "Windows10"
[String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/6ae59d69-36fc-8e4d-23dd-631d98bf74a9/atom'
[regex] $Flash = ".*Adobe Flash Player.*"

$tempDir = $env:TMPDIR
$tempFile = Join-Path -Path $tempDir -ChildPath ([System.IO.Path]::GetRandomFileName())

Invoke-WebRequest -Uri $StartKB -ContentType 'application/atom+xml; charset=utf-8' `
    -UseBasicParsing -OutFile $tempFile -ErrorAction SilentlyContinue
$xml = [xml] (Get-Content -Path $tempFile -ErrorAction SilentlyContinue)

[regex] $rxM = "(\d{4}-\d{2}-\d{2})"
[regex] $rxT = "(\d{2}:\d{2}:\d{2})"

$date = $xml.feed.entry | Where-Object { $_.title -match $Flash } | Select-Object -ExpandProperty updated | `
    ForEach-Object { Get-RxString -String $_ -RegEx $rxM } | Sort-Object | Select-Object -Last 1

$kbID = $xml.feed.entry | Where-Object { ($_.title -match $Flash) -and ($_.updated -match $date ) } | Select-Object -ExpandProperty id `
    | ForEach-Object { $_.split(':') | Select-Object -Last 1 }

$kbObj = Invoke-WebRequest -Uri "http://www.catalog.update.microsoft.com/Search.aspx?q=KB$($kbID)" `
    -UseBasicParsing -ErrorAction SilentlyContinue

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

Write-Output $output
