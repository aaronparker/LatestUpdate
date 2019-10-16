Function Get-LatestWindowsDefenderUpdate {
    <#
        .SYNOPSIS
            Retrieves the latest update for Windows Defender antimalware platform.

        .DESCRIPTION
            Retrieves the latest update for Windows Defender antimalware platform from the Windows Defender update history feed.

        .EXAMPLE

            PS C:\> Get-LatestWindowsDefenderUpdate

            This commands reads the the Windows Defender update history feed and returns an object that lists the most recent Windows Defender antimalware platform update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-defender")]
    Param (
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
        $updateFeed = Get-UpdateFeed -Uri $script:resourceStrings.UpdateFeeds.WindowsDefender

        If ($Null -ne $updateFeed) {

            # Filter the feed for servicing stack updates and continue if we get updates
            $updateList = Get-UpdateDefender -UpdateFeed $updateFeed
            Write-Verbose -Message "$($MyInvocation.MyCommand): update count is: $($updateList.Count)."

            If ($Null -ne $updateList) {

                # Get download info for each update from the catalog
                Write-Verbose -Message "$($MyInvocation.MyCommand): searching catalog for: [$($update.Title)]."
                $downloadInfoParams = @{
                    UpdateId        = $updateList.ID
                    OperatingSystem = $script:resourceStrings.SearchStrings.WindowsDefender
                }
                $downloadInfo = Get-UpdateCatalogDownloadInfo @downloadInfoParams

                # Return object to the pipeline
                If ($Null -ne $downloadInfo) {
                    Write-Output -InputObject $downloadInfo
                }
            }
        }
    }
}
