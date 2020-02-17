Function Get-LatestMonthlyRollup {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 8.1 and 7 Monthly Rollup Update.

        .DESCRIPTION
            Retrieves the latest Windows 8.1 and 7 Monthly Rollup Update from the Windows 8.1/7 update history feeds.

        .PARAMETER OperatingSystem
            Specifies the the Windows operating system version to search for updates.

        .PARAMETER Previous
            Specifies that the previous to the latest update should be returned.

        .EXAMPLE

            PS C:\> Get-LatestMonthlyRollup

            This commands reads the the Windows 8.1 update history feed and returns an object that lists the most recent Windows 8.1 Monthly Rollup Update.

        .EXAMPLE

            PS C:\> Get-LatestMonthlyRollup -OperatingSystem Windows7

            This commands reads the the Windows 7 update history feed and returns an object that lists the most recent Windows 7 Monthly Rollup Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-monthly")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_ -in $script:resourceStrings.ParameterValues.Versions87 })]
        [Alias('OS')]
        [System.String] $OperatingSystem = $script:resourceStrings.ParameterValues.Versions87[0],

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
        Write-Verbose -Message "$($MyInvocation.MyCommand): get feed for $OperatingSystem."
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.$OperatingSystem

        If ($Null -ne $updateFeed) {
            # Filter the feed for monthly rollup updates and continue if we get updates
            $gumParams = @{
                UpdateFeed = $updateFeed
            }
            If ($Previous.IsPresent) { $gumParams.Previous = $True }
            $updateList = Get-UpdateMonthly @gumParams
            Write-Verbose -Message "$($MyInvocation.MyCommand): update count is: $($updateList.Count)."

            If ($Null -ne $updateList) {
                # Get download info for each update from the catalog
                $downloadInfoParams = @{
                    UpdateId        = $updateList.ID
                    OperatingSystem = $script:resourceStrings.SearchStrings.$OperatingSystem
                    Architecture    = $script:resourceStrings.Architecture.x86x64
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

                # Return object to the pipeline
                If ($Null -ne $updateListWithArch) {
                    Write-Output -InputObject $updateListWithArch
                }
            }
        }
    }
}
