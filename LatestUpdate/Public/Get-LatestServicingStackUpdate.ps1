Function Get-LatestServicingStackUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 10 Servicing Stack Update.

        .DESCRIPTION
            Retrieves the latest Windows 10 Servicing Stack Update from the Windows 10 update history feed.

            More information on Windows 10 Servicing Stack Updates can be found here: https://docs.microsoft.com/en-us/windows/deployment/update/servicing-stack-updates

        .PARAMETER OperatingSystem
            Specifies the the Windows operating system version to search for updates.

        .PARAMETER Version
            Specifies the Windows 10 Semi-annual Channel version number. Only valid when 'Windows10' is specified for -OperatingSystem.

        .PARAMETER Previous
            Specifies that the previous to the latest update should be returned.

        .EXAMPLE

            PS C:\> Get-LatestServicingStackUpdate

            This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Servicing Stack Update.

        .EXAMPLE

            PS C:\> Get-LatestServicingStackUpdate -OperatingSystem WindowsServer

            This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows Server 2016, 2019 and Semi-Annual Channel Servicing Stack Updates.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-stack")]
    [Alias("Get-LatestServicingStack")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_ -in $script:resourceStrings.ParameterValues.VersionsAll })]
        [Alias('OS')]
        [System.String] $OperatingSystem = $script:resourceStrings.ParameterValues.VersionsAll[0],

        [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [ValidateScript( { $_ -in $script:resourceStrings.ParameterValues.Windows10Versions })]
        [System.String[]] $Version,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Previous,

        [Parameter(Mandatory = $False)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty
    )

    if ($PSBoundParameters.ContainsKey('Proxy') -or $PSBoundParameters.ContainsKey('ProxyCredential')) {
        $null = Set-Proxy -Proxy $Proxy -ProxyCredential $ProxyCredential
    }

    # If resource strings are returned we can continue
    If ($Null -ne $script:resourceStrings) {

        # Get the update feed and continue if successfully read
        Write-Verbose -Message "$($MyInvocation.MyCommand): get feed for $OperatingSystem."
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.$OperatingSystem

        If ($Null -ne $updateFeed) {
            Switch -RegEx ($OperatingSystem) {

                "Windows10" {
                    If (-not ($PSBoundParameters.ContainsKey('Version'))) {
                        $Version = @($script:resourceStrings.ParameterValues.Windows10Versions[0])
                    }
                    ForEach ($ver in $Version) {

                        # Filter the feed for servicing stack updates and continue if we get updates
                        Write-Verbose -Message "$($MyInvocation.MyCommand): search feed for version $ver."
                        $gusParams = @{
                            UpdateFeed = $updateFeed
                            Version    = $ver
                        }
                        If ($Previous.IsPresent) { $gusParams.Previous = $True }
                        $updateList = Get-UpdateServicingStack @gusParams
        
                        If ($Null -ne $updateList) {

                            # Get download info for each update from the catalog
                            Write-Verbose -Message "$($MyInvocation.MyCommand): searching catalog for: [$($update.Title)]."
                            $downloadInfoParams = @{
                                UpdateId        = $updateList.ID
                                OperatingSystem = $script:resourceStrings.SearchStrings.$OperatingSystem
                            }
                            $downloadInfo = Get-UpdateCatalogDownloadInfo @downloadInfoParams
        
                    # Add the Version and Architecture properties to the list
                    $downloadInfo | Add-Member -NotePropertyName "Version" -NotePropertyValue $ver
                    $updateListWithArchParams = @{
                        InputObject     = $downloadInfo
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
                            If ($Null -ne $updateListWithArch) {
                                Write-Output -InputObject $updateListWithArch
                            }
                        }
                    }
                }
                
                "Windows8|Windows7" {
                    If ($PSBoundParameters.ContainsKey('Version')) {
                        Write-Information -MessageData "INFO: The Version parameter is only valid for Windows10. Ignoring parameter." `
                            -InformationAction Continue -Tags UserNotify
                    }

                    # Filter the feed for servicing stack updates and continue if we get updates
                    $updateList = Get-UpdateServicingStack -UpdateFeed $updateFeed
                    Write-Verbose -Message "$($MyInvocation.MyCommand): update count is: $($updateList.Count)."
        
                    If ($Null -ne $updateList) {

                        # Get download info for each update from the catalog
                        Write-Verbose -Message "$($MyInvocation.MyCommand): searching catalog for: [$($update.Title)]."
                        $downloadInfoParams = @{
                            UpdateId        = $updateList.ID
                            OperatingSystem = $script:resourceStrings.SearchStrings.$OperatingSystem
                        }
                        $downloadInfo = Get-UpdateCatalogDownloadInfo @downloadInfoParams
    
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
                        If ($Null -ne $updateListWithArch) {
                            Write-Output -InputObject $updateListWithArch
                        }
                    }
                }
            }
        }
    }
}
