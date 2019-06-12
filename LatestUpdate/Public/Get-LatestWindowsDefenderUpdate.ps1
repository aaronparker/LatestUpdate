Function Get-LatestWindowsDefenderUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest update for Windows Defender antimalware platform.

        .DESCRIPTION
            Retrieves the latest update for Windows Defender antimalware platform from the Windows Defender update history feed.

        .EXAMPLE

        PS C:\> Get-LatestWindowsDefenderUpdate

        This commands reads the the Windows Defender update history feed and returns an object that lists the most recent Windows Defender antimalware platform update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-defender")]
    Param ()
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    # If resource strings are returned we can continue
    If ($Null -ne $resourceStrings) {
        $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.WindowsDefender

        If ($Null -ne $updateFeed) {
            # Filter the feed for servicing stack updates and continue if we get updates
            $updateList = Get-UpdateDefender -UpdateFeed $updateFeed

            If ($Null -ne $updateList) {
                # Get download info for each update from the catalog
                $downloadInfoParams = @{
                    UpdateId     = $updateList.ID
                    OS           = $resourceStrings.SearchStrings.WindowsDefender
                }
                $downloadInfo = Get-UpdateCatalogDownloadInfo @downloadInfoParams

                # Return object to the pipeline
                Write-Output -InputObject $downloadInfo
            }
        }
    }
}
