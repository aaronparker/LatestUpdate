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
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-flash")]
    [Alias("Get-LatestFlash")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.")]
        [ValidateSet('Windows10', 'Windows8')]
        [ValidateNotNullOrEmpty()]
        [Alias('OS')]
        [System.String] $OperatingSystem = 'Windows10',

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

            If ($Null -ne $updateList) {
                Switch ($OperatingSystem) {

                    "Windows10" {
                        ForEach ($ver in $Version) {
                            # Get download info for each update from the catalog
                            $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID `
                                -OperatingSystem $script:resourceStrings.SearchStrings.$OperatingSystem -SearchString $ver

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
                        # Get download info for each update from the catalog
                        $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID `
                            -OperatingSystem $script:resourceStrings.SearchStrings.$OperatingSystem

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
