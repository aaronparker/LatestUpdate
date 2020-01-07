Function Get-LatestCumulativeUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest Windows 10 Cumulative Update.

        .DESCRIPTION
            Retrieves the latest Windows 10 Cumulative Update from the Windows 10 update history feed.

            More information on Windows 10 Cumulative Updates can be found at: https://docs.microsoft.com/en-us/windows/deployment/update/

        .PARAMETER OperatingSystem
            Specifies the the Windows 10 operating system version to search for updates.

        .PARAMETER Version
            Specifies the Windows 10 Semi-annual Channel version number.

        .PARAMETER Previous
            Specifies that the previous to the latest update should be returned.

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
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows OS name.", ParameterSetName = "Default")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { $_ -in $script:resourceStrings.ParameterValues.Versions10 })]
        [Alias('OS')]
        [System.String] $OperatingSystem = $script:resourceStrings.ParameterValues.Versions10[0],

        [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Windows 10 Semi-annual Channel version number.", ParameterSetName = "Default")]
        [ValidateScript( { $_ -in $script:resourceStrings.ParameterValues.Windows10Versions })]
        [System.String[]] $Version = $script:resourceStrings.ParameterValues.Windows10Versions[0],
        [Parameter(Mandatory = $False, ParameterSetName = "Default")]
        [System.Management.Automation.SwitchParameter] $Previous,
        [Parameter(Mandatory = $False, Position = 0, HelpMessage = "Build Number", ParameterSetName = "Build")]
        [int]$Build        
    )
    
    # If resource strings are returned we can continue
    If ($Null -ne $script:resourceStrings) {

        # Get the update feed and continue if successfully read
        Write-Verbose -Message "$($MyInvocation.MyCommand): get feed for $OperatingSystem."
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.Windows10
        $updateList = New-Object -TypeName System.Collections.ArrayList

        if($Build)
        {
            $BuildList = @($Build)
        }
        else
        {
            $BuildList = $Version | ForEach-Object { $script:resourceStrings.VersionTable.Windows10Builds[$_] }
        }

        If ($Null -ne $updateFeed) {
            ForEach ($Build in $BuildList) {

                # Filter the feed for cumulative updates and continue if we get updates
                Write-Verbose -Message "$($MyInvocation.MyCommand): search feed for build $Build."
                $gucParams = @{
                    UpdateFeed = $updateFeed
                    Build = $Build
                }
                If ($Previous.IsPresent) { $gucParams.Previous = $True }
                $updateList.AddRange(@(Get-UpdateCumulative @gucParams))
                Write-Verbose -Message "$($MyInvocation.MyCommand): update count is: $($updateList.Count)."
                If ($Null -ne $updateList) {

                    # Get download info for each update from the catalog
                    Write-Verbose -Message "$($MyInvocation.MyCommand): searching catalog for: [$($updateList.Title)]."
                    $downloadInfoParams = @{
                        UpdateId        = $updateList.ID
                        OperatingSystem = $script:resourceStrings.SearchStrings.$OperatingSystem
                    }
                    $downloadInfo = Get-UpdateCatalogDownloadInfo @downloadInfoParams

                    # Add the Version and Architecture properties to the list
                    $downloadInfo | Add-Member -NotePropertyName "Build" -NotePropertyValue $Build
                    $updateListWithArchParams = @{
                        InputObject     = $downloadInfo
                        Property        = "Note"
                        NewPropertyName = "Architecture"
                        MatchPattern    = $script:resourceStrings.Matches.Architecture
                    }
                    $updateListWithArch = Add-Property @updateListWithArchParams

                    $updateListWithArchParams = @{
                        InputObject     = $downloadInfo
                        Property        = "Note"
                        NewPropertyName = "Version"
                        MatchPattern    = $script:resourceStrings.Matches.Windows10Version
                    }
                    $updateListWithArch = Add-Property @updateListWithArchParams
                    
                    # Add Revsion property
                    $updateListWithArch | Add-Member -NotePropertyName "Revision" -NotePropertyValue $updateList.Revision

                    # Remove updates where description version doesn't match specified version
                    if($null -ne $Version)
                    {
                        $updateListWithArch = $updateListWithArch | Where-Object { $_.Version -in $Version }
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
