Function Get-LatestMonthlyRollup {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 8.1 and 7 Monthly Rollup Update.

        .DESCRIPTION
            Retrieves the latest Windows 8.1 and 7 Monthly Rollup Update from the Windows 8.1/7 update history feed.

        .EXAMPLE

        PS C:\> Get-LatestMonthlyRollup

        This commands reads the the Windows 8.1 update history feed and returns an object that lists the most recent Windows 8.1 Monthly Rollup Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-monthly")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows version.")]
        [ValidateSet('Windows 8', 'Windows 7')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version = "Windows 8"
    )
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    # If resource strings are returned we can continue
    If ($Null -ne $resourceStrings) {
        Switch ($Version) {
            "Windows 8" {
                $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.Windows8
                $osName = "Windows 8.1|Windows Server"
                $matchPattern = $resourceStrings.Matches.Windows8Version
            }
            "Windows 7" {
                $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.Windows7
                $osName = "Windows 7|Windows Server"
                $matchPattern = $resourceStrings.Matches.Windows7Version
            }
        }
        If ($Null -ne $updateFeed) {

            # Filter the feed for monthly rollup updates and continue if we get updates
            $updateList = Get-UpdateMonthly -UpdateFeed $updateFeed
            If ($Null -ne $updateList) {

                # Get download info for each update from the catalog
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID -OS $osName -Architecture 'x86|x64'
                $filteredDownloadInfo = $downloadInfo | Sort-Object -Unique -Property Note

                # Add the Version and Architecture properties to the list
                $updateListWithVersionParams = @{
                    InputObject = $filteredDownloadInfo
                    Property = "Note"
                    NewPropertyName = "Version"
                    MatchPattern = $matchPattern
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
