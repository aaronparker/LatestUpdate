<#
    .SYNOPSIS
        Downloads the latest updates to a target folder.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://docs.stealthpuppy.com/docs/latestupdate
#>
[CmdletBinding(SupportsShouldProcess = $False)]
Param (
    [Parameter(Mandatory = $False, HelpMessage = "Specify a folder to save the updates to.")]
    [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
    [ValidateNotNullOrEmpty()]
    [System.String] $UpdatePath = $PWD,
            
    [Parameter(Mandatory = $False)]
    [System.String] $Version = "1903",
    
    [Parameter(Mandatory = $False)]
    [System.String] $Architecture = "x64"
)
    
# Download the updates
Write-Host "Downloading cumulative updates." -ForegroundColor Cyan
Get-LatestCumulativeUpdate -Version $Version | Where-Object { $_.Architecture -eq $Architecture } | Save-LatestUpdate -Path $UpdatePath -Method WebClient
    
Write-Host "Downloading servicing stack updates." -ForegroundColor Cyan
Get-LatestServicingStackUpdate -Version $Version | Where-Object { $_.Architecture -eq $Architecture } | Save-LatestUpdate -Path $UpdatePath -Method WebClient
    
Write-Host "Downloading servicing stack updates." -ForegroundColor Cyan
Get-LatestAdobeFlashUpdate -Version $Version | Where-Object { $_.Architecture -eq $Architecture } | Save-LatestUpdate -Path $UpdatePath -Method WebClient
    
Write-Host "Downloading Windows Defender updates." -ForegroundColor Cyan
Get-LatestWindowsDefenderUpdate | Save-LatestUpdate -Path $UpdatePath -Method WebClient
    
Write-Host "Downloading .NET Framework updates." -ForegroundColor Cyan
Get-LatestNetFrameworkUpdate | Where-Object { $_.Version -eq $Version } | Where-Object { $_.Architecture -eq $Architecture } | Save-LatestUpdate -Path $UpdatePath -Method WebClient
