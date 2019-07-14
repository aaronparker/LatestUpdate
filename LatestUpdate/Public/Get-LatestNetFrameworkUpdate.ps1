Function Get-LatestNetFrameworkUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest .NET Framework Cumulative Updates.

        .DESCRIPTION
            Retrieves the latest .NET Framework Cumulative Update from the .NET Framework update history feed.

        .PARAMETER OperatingSystem
            Specifies the the Windows operating system version to search for updates.

        .EXAMPLE

        PS C:\> Get-LatestNetFrameworkUpdate

        This commands reads the the .NET Framework update history feed and returns an object that lists the most recent Windows 10 .NET Framework Cumulative Updates.

        .EXAMPLE

        PS C:\> Get-LatestNetFrameworkUpdate -OperatingSystem WindowsClient

        This commands reads the the Windows update history feeds and returns an object that lists the most recent Windows 10/8.1/7 .NET Framework Cumulative Updates.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-net")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.")]
        [ValidateNotNullOrEmpty()]
        [Alias('OS')]
        [System.String] $OperatingSystem = $script:resourceStrings.ParameterValues.VersionsComplete[0]
    )

    # If resource strings are returned we can continue
    If ($Null -ne $script:resourceStrings) {
        # Get the update feed and continue if successfully read
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.NetFramework

        If ($Null -ne $updateFeed) {
            
            # Filter the feed for .NET Framework updates
            Write-Verbose -Message "$($MyInvocation.MyCommand): filter feed for [$($script:resourceStrings.SearchStrings.$OperatingSystem)]."
            $updateList = Get-UpdateNetFramework -UpdateFeed $updateFeed | `
                Where-Object { $_.Title -match $script:resourceStrings.SearchStrings.$OperatingSystem }
            Write-Verbose -Message "$($MyInvocation.MyCommand): update count is: $($updateList.Count)."

            # Filter again for updates from the most recent month, otherwise we have too many updates
            $updateList = $updateList | Sort-Object -Property Updated -Descending
            $updateList = $updateList | Where-Object { $_.Updated.Month -eq $updateList[0].Updated.Month }                
            Write-Verbose -Message "$($MyInvocation.MyCommand): filtered to $($updateList.Count) items."

            If ($Null -ne $updateList) {
                ForEach ($update in $updateList) {
                    # Get download info for each update from the catalog
                    Write-Verbose -Message "$($MyInvocation.MyCommand): searching catalog for: [$($update.Title)]."
                    $downloadInfoParams = @{
                        UpdateId        = $update.ID
                        OperatingSystem = $script:resourceStrings.SearchStrings.$OperatingSystem
                    }
                    $downloadInfo = Get-UpdateCatalogDownloadInfo @downloadInfoParams

                    If ($downloadInfo) {
                        
                        # Add the Version and Architecture properties to the list
                        $updateListWithVersionParams = @{
                            InputObject     = $downloadInfo
                            Property        = "Note"
                            NewPropertyName = "Version"
                            MatchPattern    = $script:resourceStrings.Matches."$($OperatingSystem)Version"
                        }
                        $updateListWithVersion = Add-Property @updateListWithVersionParams
                        $updateListWithArchParams = @{
                            InputObject     = $updateListWithVersion
                            Property        = "Note"
                            NewPropertyName = "Architecture"
                            MatchPattern    = $script:resourceStrings.Matches.Architecture
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

                        # Output to pipeline
                        Write-Output -InputObject $updateListWithArch
                    }
                }
            }
        }
    }
}
