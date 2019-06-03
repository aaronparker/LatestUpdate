Function Get-LatestCumulativeUpdate {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    [Alias("Get-LatestUpdate")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [ValidateSet('1903', '1809', '1803', '1709', '1703', '1607')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Version = "1903"
    )
    
    # Get module strings from the JSON
    $strings = Get-ModuleStrings

    If ($Null -ne $strings) {
        ForEach ($ver in $Version) {
            $updateFeed = Get-UpdateFeed -Uri $strings.UpdateFeeds.Windows10
            $updateList = Get-Windows10CumulativeUpdate -Build $strings.VersionTable.Windows10[$ver] -UpdateFeed $updateFeed
            If ($Null -ne $updateList) {
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID
                Write-Output -InputObject $downloadInfo
            }
        }
    }
}
