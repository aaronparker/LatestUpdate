Function Get-LatestServicingStackUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 10 Servicing Stack Update.

        .DESCRIPTION
            Retrieves the latest Windows 10 Servicing Stack Update from the Windows 10 update history feed.

            More information on Windows 10 Servicing Stack Updates can be found here: https://docs.microsoft.com/en-us/windows/deployment/update/servicing-stack-updates

        .EXAMPLE

        PS C:\> Get-LatestServicingStackUpdate

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Servicing Stack Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-stack")]
    [Alias("Get-LatestServicingStack")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.")]
        [ValidateNotNullOrEmpty()]
        [Alias('OS')]
        [System.String] $OperatingSystem = $script:resourceStrings.ParameterValues.VersionsAll[0],

        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [System.String[]] $Version
    )

    # If resource strings are returned we can continue
    If ($Null -ne $script:resourceStrings) {
        # Get the update feed and continue if successfully read
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.$OperatingSystem

        If ($Null -ne $updateFeed) {
            Switch -RegEx ($OperatingSystem) {

                "Windows10" {
                    If ($Null -eq $Version) { $Version = @($script:resourceStrings.VersionTable.Windows10Versions[0]) }
                    ForEach ($ver in $Version) {
                        # Filter the feed for servicing stack updates and continue if we get updates
                        $updateList = Get-UpdateServicingStack -UpdateFeed $updateFeed -Version $ver
        
                        If ($Null -ne $updateList) {
                            # Get download info for each update from the catalog
                            $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID `
                                -OperatingSystem $script:resourceStrings.SearchStrings.$OperatingSystem
        
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
        
                            # Return object to the pipeline
                            Write-Output -InputObject $updateListWithArch
                        }
                    }
                }
                
                "Windows8|Windows7" {
                    If ($PSBoundParameters.ContainsKey('Version')) {
                        Write-Information -Message "INFO: The Version parameter is only valid for Windows10. Ignoring parameter." -InformationAction Continue
                    }

                    # Filter the feed for servicing stack updates and continue if we get updates
                    $updateList = Get-UpdateServicingStack -UpdateFeed $updateFeed
        
                    If ($Null -ne $updateList) {
                        # Get download info for each update from the catalog
                        $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID `
                            -OperatingSystem $script:resourceStrings.SearchStrings.$OperatingSystem
    
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
    
                        # Return object to the pipeline
                        Write-Output -InputObject $updateListWithArch
                    }
                }
            }
        }
    }
}
