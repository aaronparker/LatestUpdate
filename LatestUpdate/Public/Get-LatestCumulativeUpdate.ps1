Function Get-LatestCumulativeUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 10 Cumulative Update.

        .DESCRIPTION
            Retrieves the latest Windows 10 Cumulative Update from the Windows 10 update history feed.

            More information on Windows 10 Cumulative Updates can be found here: https://docs.microsoft.com/en-us/windows/deployment/update/

        .EXAMPLE

        PS C:\> Get-LatestCumulativeUpdate

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Cumulative Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    [Alias("Get-LatestUpdate")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS Name")]
        [ValidateSet('Windows10', 'WindowsClient', 'WindowsServer', 'All')]
        [ValidateNotNullOrEmpty()]
        [System.String] $OS = 'Windows10',

        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
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

                # Filter the feed for cumulative updates and continue if we get updates
                $updateList = Get-UpdateCumulative -UpdateFeed $updateFeed -Build $resourceStrings.VersionTable.$($OS)[$ver]
                If ($Null -ne $updateList) {

                    # Get download info for each update from the catalog
                    $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID

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
}
