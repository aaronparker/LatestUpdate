Function Get-LatestNetFrameworkUpdate {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/get-latest")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, HelpMessage = "Windows 10 Semi-annual Channel version number.")]
        [ValidateSet('1903', '1809', '1803', '1709', '1703', '1607')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Version = "1903"
    )
    
    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    If ($Null -ne $resourceStrings) {
        $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.NetFramework
        If ($Null -ne $updateFeed) {
            $updateList = Get-UpdateNetFramework -UpdateFeed $updateFeed
            If ($Null -ne $updateList) {
                ForEach ($update in $updateList) {
                    $downloadInfo = Get-UpdateCatalogDownloadInfo -UpdateId $update.ID -OS $resourceStrings.SearchStrings.NetFrameworkWindows10 -Architecture ""
                    $filteredDownloadInfo = $downloadInfo | Sort-Object -Unique -Property Description
                    $updateListWithVersion = Add-Property -InputObject $filteredDownloadInfo -Property "Description" -NewPropertyName "Version" `
                        -MatchPattern $resourceStrings.Matches.Windows10Version
                    $updateListWithArch = Add-Property -InputObject $updateListWithVersion -Property "Description" -NewPropertyName "Architecture" `
                        -MatchPattern $resourceStrings.Matches.Architecture
                    
                    $i = 0
                    ForEach ($update in $updateListWithArch) {
                        If ($update.Architecture.Length -eq 0) {
                            $updateListWithArch[$i].Architecture = "x86"
                        }
                        $i++
                    }
                    Write-Output -InputObject $updateListWithArch
                }
            }
        }
    }
}
