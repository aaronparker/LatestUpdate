Function Get-LatestNetFrameworkUpdate {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [ValidateSet('1903', '1809', '1803', '1709', '1703', '1607')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Version = "1903"
    )
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    If ($Null -ne $resourceStrings) {
        $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.NetFramework
        $updateList = Get-UpdateNetFramework -UpdateFeed $updateFeed
        If ($Null -ne $updateList) {
            ForEach ($update in $updateList) {
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $update.ID -OS $resourceStrings.SearchStrings.NetFrameworkWindows10 -Architecture ""
                $filteredDownloadInfo = $downloadInfo | Sort-Object -Unique -Property Description
                Write-Output -InputObject $filteredDownloadInfo
            }
        }
    }
}
