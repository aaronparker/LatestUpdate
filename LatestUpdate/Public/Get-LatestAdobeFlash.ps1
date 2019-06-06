Function Get-LatestAdobeFlash {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-flash")]
    [Alias("Get-LatestFlash")]
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
            If ($Null -ne $updateFeed) {
                $updateList = Get-UpdateAdobeFlash -UpdateFeed $updateFeed
                If ($Null -ne $updateList) {
                    $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID
                    $updateListWithVersion = Add-Property -InputObject $downloadInfo -Property "Description" -NewPropertyName "Version" `
                        -MatchPattern $resourceStrings.Matches.Windows10Version
                    $updateListWithArch = Add-Property -InputObject $updateListWithVersion -Property "Description" -NewPropertyName "Architecture" `
                        -MatchPattern $resourceStrings.Matches.Architecture
                    Write-Output -InputObject $updateListWithArch
                }
            }
        }
    }
}
