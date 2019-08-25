Set-PSBreakpoint -Variable Now -Action { $global:now = Get-Date -f 'dd\/MM\/yyyy HH:mm:ss:ffff' } -Mode Read | Out-Null
$null = $Now

function Get-HumanReadableFileSize {
    param (
        $Path
    )
    $bytecount = (Get-Item -Path $Path).Length
    switch -Regex ([math]::truncate([math]::log($bytecount, 1024))) {
        '^0' { "$bytecount Bytes" }
        '^1' { "{0:n2} KB" -f ($bytecount / 1KB) }
        '^2' { "{0:n2} MB" -f ($bytecount / 1MB) }
        '^3' { "{0:n2} GB" -f ($bytecount / 1GB) }
        '^4' { "{0:n2} TB" -f ($bytecount / 1TB) }
        Default { "{0:n2} PB" -f ($bytecount / 1pb) }
    }
}

function Get-TimeString {
    param (
        [timespan] $time
    )
    if ($time.Minutes -eq 0) {
        return "$($time.seconds) Seconds and $($time.Milliseconds) Milliseconds"
    }
    else {
        return "$($time.Minutes) Minutes, $($time.seconds) Seconds and $($time.Milliseconds) Milliseconds"
    }
}

Write-Output ""

Write-Output "$Now Start search for latest Adobe Flash update for Server 2019"
$time = Measure-Command -Expression {
    $updates = Get-LatestAdobeFlashUpdate -OperatingSystem WindowsServer
    $update = $updates | Where-Object { $_.Note -match 'Windows Server 2019' }
}
Write-Output "$Now Found update $($update.Note)"
Write-Output "$Now Finding the update took $($time.seconds) Seconds and $($time.Milliseconds) Milliseconds"

Start-Sleep -S 3

Write-Output "$Now Starting download using WebRequest:"
$time = Measure-Command -Expression { $result = $update | Save-LatestUpdate -Path c:\temp -Method WebRequest -Force }
Write-Output "$Now Download took $(Get-TimeString -Time $time)"
Write-Output "$Now Size of downloaded file is: $(Get-HumanReadableFileSize -Path $result.Path)"

Start-Sleep -S 3

Write-Output "$Now Starting download using WebClient:"
$time = Measure-Command -Expression { $result = $update | Save-LatestUpdate -Path c:\temp -Method WebClient -Force }
Write-Output "$Now Download took $(Get-TimeString -Time $time)"
Write-Output "$Now Size of downloaded file is: $(Get-HumanReadableFileSize -Path $result.Path)"

Write-Output ""
Start-Sleep -S 3

Write-Output "$Now Start search for latest Cumulative Update for Server 2016"
$time = Measure-Command -Expression {
    $updates = Get-LatestCumulativeUpdate -Version 1607
    $update = $updates | Where-Object { $_.Note -match 'Windows Server 2016' }
}
Write-Output "$Now Found update $($update.Note)"
Write-Output "$Now Finding the update took $($time.seconds) Seconds and $($time.Milliseconds) Milliseconds"

Start-Sleep -S 3

Write-Output "$Now Starting download using WebRequest:"
$time = Measure-Command -Expression { $result = $update | Save-LatestUpdate -Path c:\temp -Method WebRequest -Force }
Write-Output "$Now Download took $(Get-TimeString -Time $time)"
Write-Output "$Now Size of downloaded file is: $(Get-HumanReadableFileSize -Path $result.Path)"

Start-Sleep -S 3

Write-Output "$Now Starting download using WebClient:"
$time = Measure-Command -Expression { $result = $update | Save-LatestUpdate -Path c:\temp -Method WebClient -Force }
Write-Output "$Now Download took $(Get-TimeString -Time $time)"
Write-Output "$Now Size of downloaded file is: $(Get-HumanReadableFileSize -Path $result.Path)"

Write-Output ""
