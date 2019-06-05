Function Get-LatestServicingStack {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-stack")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [ValidateSet('1903', '1809', '1803', '1709', '1703', '1607')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Version = "1903"
    )
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    If ($Null -ne $resourceStrings) {
        ForEach ($ver in $Version) {
            $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.Windows10
            $updateList = Get-UpdateServicingStack -Version $ver -UpdateFeed $updateFeed
            If ($Null -ne $updateList) {
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID
                Write-Output -InputObject $downloadInfo
            }
        }
    }
}
