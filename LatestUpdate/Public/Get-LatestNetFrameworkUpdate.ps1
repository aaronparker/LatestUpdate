Function Get-LatestNetFrameworkUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest .NET Framework Cumulative Updates.

        .DESCRIPTION
            Retrieves the latest .NET Framework Cumulative Updates from the .NET Framework update history feed. Updates returned will be the most recent updates (i.e. released in the most recent month).

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
        [ValidateScript( { $_ -in $script:resourceStrings.ParameterValues.VersionsComplete })]
        [Alias('OS')]
        [System.String] $OperatingSystem = $script:resourceStrings.ParameterValues.VersionsComplete[0],

        [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [ValidateScript( { $_ -in $script:resourceStrings.ParameterValues.Windows10Versions })]
        [System.String[]] $Version = $script:resourceStrings.ParameterValues.Windows10Versions[0],
        
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
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.NetFramework

        If ($Null -ne $updateFeed) {
            ForEach ($ver in $Version) {
                # Filter the feed for .NET Framework Updates and continue if we get updates
                Write-Verbose -Message "$($MyInvocation.MyCommand): search feed for version $ver."
                $gnfuParams = @{
                    UpdateFeed = $updateFeed
                    Version = $ver
                }
                If ($Previous.IsPresent) { $gnfuParams.Previous = $True }
                # Filter the feed for .NET Framework updates
                Write-Verbose -Message "$($MyInvocation.MyCommand): filter feed for version [$ver]."
                $updateList = Get-UpdateNetFramework @gnfuParams
                Write-Verbose -Message "$($MyInvocation.MyCommand): update count is: $($updateList.Count)."

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
                            $updateListWithArch | Add-Member -NotePropertyName "Updated" -NotePropertyValue $update.Updated.Date
                        }
                        $updateListAll += $updateListWithArch
                    }
                    # If the value for Architecture is blank, make it "x86"
                    $i = 0
                    ForEach ($update in $updateListAll) {
                        If ($update.Architecture.Length -eq 0) {
                            $updateListAll[$i].Architecture = "x86"
                        }
                        $i++
                    }

                    If($null -ne $Version) {
                        $updateListAll = $updateListAll | Where-Object {$_.Version -match $Version}
                    }
                    
                    If ($Previous.IsPresent) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): selecting previous update"
                        $latestUpdate = ($updateListAll | Sort-Object Updated -Descending | Group-Object -Property Updated | Select -First 2 | Select -Last 1).Group
                    }
                    Else {
                        $latestUpdate = ($updateListAll | Sort-Object Updated -Descending | Group-Object -Property Updated | Select -First 1).Group
                    }

                    # Output to pipeline
                    If ($Null -ne $latestUpdate) {
                        Write-Output -InputObject $latestUpdate
                    }
                }
            }
        }
    }
}
    

