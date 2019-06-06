Function Get-LatestMonthlyRollup {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows version.")]
        [ValidateSet('Windows 8', 'Windows 7')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version = "Windows 8"
    )
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    If ($Null -ne $resourceStrings) {
        Switch ($Version) {
            "Windows 8" {
                $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.Windows8
                $osName = "Windows 8.1|Windows Server"
            }
            "Windows 7" {
                $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.Windows7
                $osName = "Windows 7|Windows Server"
            }
        }
        If ($Null -ne $updateFeed) {
            $updateList = Get-UpdateMonthly -UpdateFeed $updateFeed
            If ($Null -ne $updateList) {
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $updateList.ID -OS $osName -Architecture 'x86|x64'
                $filteredDownloadInfo = $downloadInfo | Sort-Object -Unique -Property Description
                $updateListWithVersion = Add-Property -InputObject $filteredDownloadInfo -Property "Description" -NewPropertyName "Version" `
                    -MatchPattern $resourceStrings.Matches.Windows10Version
                $updateListWithArch = Add-Property -InputObject $updateListWithVersion -Property "Description" -NewPropertyName "Architecture" `
                    -MatchPattern $resourceStrings.Matches.Architecture
                Write-Output -InputObject $updateListWithArch
            }
        }
    }
}
