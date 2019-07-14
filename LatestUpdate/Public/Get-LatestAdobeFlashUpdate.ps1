Function Get-LatestAdobeFlashUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest Adobe Flash Player Updates.

        .DESCRIPTION
            Retrieves the latest Adobe Flash Player Update from the Windows update history feeds.

        .PARAMETER OperatingSystem
            Specifies the the Windows operating system version to search for updates.

        .PARAMETER Version
            Specifies the Windows 10 Semi-annual Channel version number. Only valid when 'Windows10' is specified for -OperatingSystem.

        .EXAMPLE

        PS C:\> Get-LatestAdobeFlashUpdate

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Semi-annual Channel Adobe Flash Player Updates.

        .EXAMPLE

        PS C:\> Get-LatestAdobeFlashUpdate -OperatingSystem Windows10 -Version 1809

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 1809 Adobe Flash Player Updates.

        .EXAMPLE

        PS C:\> Get-LatestAdobeFlashUpdate -Version 1809

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 1809 Adobe Flash Player Updates.

        .EXAMPLE

        PS C:\> Get-LatestAdobeFlashUpdate -OperatingSystem Windows8

        This commands reads the the Windows 8 update history feed and returns an object that lists the most recent Adobe Flash Player Updates.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-flash")]
    [Alias("Get-LatestFlash")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.")]
        [ValidateNotNullOrEmpty()]
        [Alias('OS')]
        [System.String] $OperatingSystem = $script:resourceStrings.ParameterValues.Versions108[0],

        [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [System.String[]] $Version = $script:resourceStrings.ParameterValues.Windows10Versions[0]
    )
    
    # If resource strings are returned we can continue
    If ($Null -ne $script:resourceStrings) {
        
        # Get the update feed and continue if successfully read
        Write-Verbose -Message "$($MyInvocation.MyCommand): get feed for $OperatingSystem."
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.$OperatingSystem
        If ($Null -ne $updateFeed) {

            # Filter the feed for Adobe Flash updates and continue if we get updates
            $updateList = Get-UpdateAdobeFlash -UpdateFeed $updateFeed
            Write-Verbose -Message "$($MyInvocation.MyCommand): update count is: $($updateList.Count)."

            If ($Null -ne $updateList) {
                Switch ($OperatingSystem) {

                    "Windows10" {
                        ForEach ($ver in $Version) {
                            # Get download info for each update from the catalog
                            Write-Verbose -Message "$($MyInvocation.MyCommand): searching catalog for: [$($update.Title)]."
                            $downloadInfoParams = @{
                                UpdateId        = $updateList.ID
                                OperatingSystem = $script:resourceStrings.SearchStrings.$OperatingSystem
                                SearchString    = $ver
                            }
                            $downloadInfo = Get-UpdateCatalogDownloadInfo @downloadInfoParams

                            If ($Null -ne $downloadInfo) {

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
                
                                # Return object to the pipeline
                                Write-Output -InputObject $updateListWithArch
                            }
                        }
                    }

                    "Windows8" {
                        If ($PSBoundParameters.ContainsKey('Version')) {
                            Write-Information -MessageData "INFO: The Version parameter is only valid for Windows10. Ignoring parameter." `
                                -InformationAction Continue -Tags UserNotify
                        }

                        # Get download info for each update from the catalog
                        Write-Verbose -Message "$($MyInvocation.MyCommand): searching catalog for: [$($update.Title)]."
                        $downloadInfoParams = @{
                            UpdateId        = $updateList.ID
                            OperatingSystem = $script:resourceStrings.SearchStrings.$OperatingSystem
                        }
                        $downloadInfo = Get-UpdateCatalogDownloadInfo @downloadInfoParams

                        If ($Null -ne $downloadInfo) {

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
                
                            # Return object to the pipeline
                            Write-Output -InputObject $updateListWithArch
                        }
                    }
                }
            }
        }
    }
}
