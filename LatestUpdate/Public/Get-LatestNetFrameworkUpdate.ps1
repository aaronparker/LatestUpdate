Function Get-LatestNetFrameworkUpdate {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows version.")]
        [ValidateSet('Windows 10', 'Windows 8', 'Windows 7')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version = "Windows 8",

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Architecture = 'x64|x86'
    )
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    If ($Null -ne $resourceStrings) {
        Switch ($Version) {
            "Windows 10" {
                $osName = "Windows 10|Windows Server"
            }
            "Windows 8" {
                $osName = "Windows 8.1|Windows Server"
            }
            "Windows 7" {
                $osName = "Windows 7|Windows Server"
            }
        }
        $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.NetFramework
        $updateList = Get-UpdateNetFramework -UpdateFeed $updateFeed
        If ($Null -ne $updateList) {
            ForEach ($update in $updateList) {
                $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $update.ID -OS $osName -Architecture $Architecture
                $filteredDownloadInfo = $downloadInfo | Sort-Object -Unique -Property Description
                Write-Output -InputObject $filteredDownloadInfo
            }
        }
    }
}
