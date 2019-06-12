Function Get-LatestAdobeFlashUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 10 Adobe Flash Player Update.

        .DESCRIPTION
            Retrieves the latest Windows 10 Adobe Flash Player Update from the Windows 10 update history feed.

        .EXAMPLE

        PS C:\> Get-LatestAdobeFlashUpdate

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Adobe Flash Player Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-flash")]
    [Alias("Get-LatestFlash")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS Name")]
        [ValidateSet('Windows10', 'Windows8')]
        [ValidateNotNullOrEmpty()]
        [System.String] $OS = 'Windows10'
    )
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    # If resource strings are returned we can continue
    If ($Null -ne $resourceStrings) {
        # Get the update feed and continue if successfully read
        $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.$OS

        If ($Null -ne $updateFeed) {
            # Filter the feed for Adobe Flash updates and continue if we get updates
            $updateList = Get-UpdateAdobeFlash -UpdateFeed $updateFeed

            If ($Null -ne $updateList) {
                # Get download info for each update from the catalog
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID -OS $resourceStrings.SearchStrings.$OS

                # Add the Version and Architecture properties to the list
                $updateListWithVersionParams = @{
                    InputObject = $downloadInfo
                    Property = "Note"
                    NewPropertyName = "Version"
                    MatchPattern = $resourceStrings.Matches."$($OS)Version"
                }
                $updateListWithVersion = Add-Property @updateListWithVersionParams

                $updateListWithArchParams = @{
                    InputObject = $updateListWithVersion
                    Property = "Note"
                    NewPropertyName = "Architecture"
                    MatchPattern = $resourceStrings.Matches.Architecture
                }
                $updateListWithArch = Add-Property @updateListWithArchParams

                # Return object to the pipeline
                Write-Output -InputObject $updateListWithArch
            }
        }
    }
}
