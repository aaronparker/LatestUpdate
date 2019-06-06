Function Get-LatestAdobeFlashUpdate {
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

    # If resource strings are returned we can continue
    If ($Null -ne $resourceStrings) {
        ForEach ($ver in $Version) {

            # Get the update feed and continue if successfully read
            $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.Windows10
            If ($Null -ne $updateFeed) {

                # Filter the feed for Adobe Flash updates and continue if we get updates
                $updateList = Get-UpdateAdobeFlash -UpdateFeed $updateFeed
                If ($Null -ne $updateList) {

                    # Get download info for each update from the catalog
                    $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID

                    # Add the Version and Architecture properties to the list
                    $updateListWithVersion = Add-Property -InputObject $downloadInfo -Property "Note" -NewPropertyName "Version" `
                        -MatchPattern $resourceStrings.Matches.Windows10Version
                    $updateListWithArch = Add-Property -InputObject $updateListWithVersion -Property "Note" -NewPropertyName "Architecture" `
                        -MatchPattern $resourceStrings.Matches.Architecture

                    # Return object to the pipeline
                    Write-Output -InputObject $updateListWithArch
                }
            }
        }
    }
}
