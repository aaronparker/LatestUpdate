Function Get-LatestCumulativeUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 10 Cumulative Update.

        .DESCRIPTION
            Retrieves the latest Windows 10 Cumulative Update from the Windows 10 update history feed.

            More information on Windows 10 Cumulative Updates can be found here: https://docs.microsoft.com/en-us/windows/deployment/update/

        .PARAMETER OperatingSystem
            Specifies the the Windows 10 operating system version to search for updates.

        .PARAMETER Version
            Specifies the Windows 10 Semi-annual Channel version number.

        .EXAMPLE

        PS C:\> Get-LatestCumulativeUpdate

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Semi-annual Channel Cumulative Update.

        .EXAMPLE

        PS C:\> Get-LatestCumulativeUpdate -Version 1809

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 1809 Cumulative Update.

        .EXAMPLE

        PS C:\> Get-LatestCumulativeUpdate -OperatingSystem WindowsServer -Version 1809

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows Server 2019 Cumulative Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    [Alias("Get-LatestUpdate")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.")]
        [ValidateNotNullOrEmpty()]
        [Alias('OS')]
        [System.String] $OperatingSystem = $script:resourceStrings.ParameterValues.Windows10[0],

        [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [System.String[]] $Version = $script:resourceStrings.ParameterValues.Windows10Versions[0]
    )
    
    # If resource strings are returned we can continue
    If ($Null -ne $script:resourceStrings) {
        # Get the update feed and continue if successfully read
        Write-Verbose -Message "$($MyInvocation.MyCommand): get feed for $OperatingSystem."
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.Windows10

        If ($Null -ne $updateFeed) {
            ForEach ($ver in $Version) {

                # Filter the feed for cumulative updates and continue if we get updates
                Write-Verbose -Message "$($MyInvocation.MyCommand): search feed for version $ver."
                $updateList = Get-UpdateCumulative -UpdateFeed $updateFeed `
                    -Build $script:resourceStrings.VersionTable.Windows10Builds[$ver]

                If ($Null -ne $updateList) {
                    # Get download info for each update from the catalog
                    $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID `
                        -OperatingSystem $script:resourceStrings.SearchStrings.$OperatingSystem

                    # Add the Version and Architecture properties to the list
                    $updateListWithVersionParams = @{
                        InputObject     = $downloadInfo
                        Property        = "Note"
                        NewPropertyName = "Version"
                        MatchPattern    = $script:resourceStrings.Matches.Windows10Version
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
