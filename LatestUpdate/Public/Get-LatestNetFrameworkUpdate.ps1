Function Get-LatestNetFrameworkUpdate {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [ValidateSet('Windows 10', 'Windows 8', 'Windows 7')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version = "Windows 10"
    )
    
    # Get module strings from the JSON
    $strings = Get-ModuleResource

    If ($Null -ne $strings) {
        $updateFeed = Get-UpdateFeed -Uri $strings.UpdateFeeds.NetFramework
        $updateList = Get-NetFrameworkUpdate -UpdateFeed $updateFeed
        Write-Host $updateList
        If ($Null -ne $updateList) {
            ForEach ($update in $updateList) {
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $update.ID -OS $Version
                Write-Output -InputObject $downloadInfo
            }
        }
    }
}
