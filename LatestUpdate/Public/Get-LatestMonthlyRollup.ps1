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
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-monthly")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.")]
        [ValidateSet('Windows8', 'Windows7')]
        [ValidateNotNullOrEmpty()]
        [Alias('OS')]
        [System.String] $OperatingSystem = "Windows8"
    )
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    # If resource strings are returned we can continue
    If ($Null -ne $resourceStrings) {
        $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.$OperatingSystem

        If ($Null -ne $updateFeed) {
            # Filter the feed for monthly rollup updates and continue if we get updates
            $updateList = Get-UpdateMonthly -UpdateFeed $updateFeed

            If ($Null -ne $updateList) {
                # Get download info for each update from the catalog
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID `
                    -OperatingSystem $resourceStrings.SearchStrings.$OperatingSystem `
                    -Architecture $resourceStrings.Architecture.x86x64

                # Add the Version property to the list
                $updateListWithVersionParams = @{
                    InputObject     = $downloadInfo
                    Property        = "Note"
                    NewPropertyName = "Version"
                    MatchPattern    = $resourceStrings.Matches."$($OperatingSystem)Version"
                }
                $updateListWithVersion = Add-Property @updateListWithVersionParams

                # Add Architecture property to the list
                $updateListWithArchParams = @{
                    InputObject     = $updateListWithVersion
                    Property        = "Note"
                    NewPropertyName = "Architecture"
                    MatchPattern    = $resourceStrings.Matches.Architecture
                }
                $updateListWithArch = Add-Property @updateListWithArchParams

                # Return object to the pipeline
                Write-Output -InputObject $updateListWithArch
            }
        }
    }
}
