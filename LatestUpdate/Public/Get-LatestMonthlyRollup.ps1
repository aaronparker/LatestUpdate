Function Get-LatestMonthlyRollup {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [ValidateSet('Windows 8', 'Windows 7')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version = "Windows 8"
    )
    
    # Get module strings from the JSON
    $strings = Get-ModuleResource

    If ($Null -ne $strings) {
        Switch ($Version) {
            "Windows 8" {
                $updateFeed = Get-UpdateFeed -Uri $strings.UpdateFeeds.Windows8
                $osName = "Windows 8.1"
            }
            "Windows 7" {
                $updateFeed = Get-UpdateFeed -Uri $strings.UpdateFeeds.Windows7
                $osName = "Windows 7"
            }
        }
        $updateList = Get-WindowsMonthlyUpdate -UpdateFeed $updateFeed
        If ($Null -ne $updateList) {
            $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID -OS $osName
            Write-Output -InputObject $downloadInfo
        }
    }
}
