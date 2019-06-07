Function Get-LatestNetFrameworkUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 10 .NET Framework Cumulative Update.

        .DESCRIPTION
            Retrieves the latest Windows 10 .NET Framework Cumulative Update from the Windows 10 update history feed.

        .EXAMPLE

        PS C:\> Get-LatestNetFrameworkUpdate

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 .NET Framework Cumulative Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-net")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS Name")]
        [ValidateSet('Windows7', 'Windows8', 'Windows10', 'WindowsClient', 'WindowsServer', 'WindowsAll')]
        [ValidateNotNullOrEmpty()]
        [System.String] $OS = 'Windows10'
    )

    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    # If resource strings are returned we can continue
    If ($Null -ne $resourceStrings) {
        
        # Get the update feed and continue if successfully read
        $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.NetFramework
        If ($Null -ne $updateFeed) {

            # Filter the feed for NET Framework updates and continue if we get updates
            $updateList = Get-UpdateNetFramework -UpdateFeed $updateFeed | Where-Object { $_.Title -match $resourceStrings.SearchStrings.$OS }

            If ($Null -ne $updateList) {
                ForEach ($update in $updateList) {

                    # Get download info for each update from the catalog
                    $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $update.ID -OS $resourceStrings.SearchStrings.$OS -Architecture "" | Where-Object { $_.Note }
                    $filteredDownloadInfo = $downloadInfo | Sort-Object -Unique -Property Note

                    if ($filteredDownloadInfo) {
                        # Add the Version and Architecture properties to the list
                        $updateListWithVersionParams = @{
                            InputObject = $filteredDownloadInfo
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

                        # If the value for Architecture is blank, make it "x86"
                        $i = 0
                        ForEach ($update in $updateListWithArch) {
                            If ($update.Architecture.Length -eq 0) {
                                $updateListWithArch[$i].Architecture = "x86"
                            }
                            $i++
                        }

                        # Return object to the pipeline
                        Write-Output -InputObject $updateListWithArch
                    }
                }
            }
        }
    }
}
