Function Get-NetFrameworkUpdate {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param (
        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Xml.XmlNode] $UpdateFeed
    )

    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    # Filter object matching desired update type
    $updateList = New-Object -TypeName System.Collections.ArrayList
    ForEach ($item in $UpdateFeed.feed.entry) {
        If ($item.title -match $resourceStrings.SearchStrings.NetFramework) {
            $PSObject = [PSCustomObject] @{
                Title   = $item.title
                ID      = $item.id
                Updated = $item.updated
            }
            $updateList.Add($PSObject) | Out-Null
        }
    }

    # Filter and select the most current update
    If ($updateList.Count -ge 1) {
        $sortedUpdateList = New-Object -TypeName System.Collections.ArrayList
        ForEach ($update in $updateList) {
            $PSObject = [PSCustomObject] @{
                Title    = $update.title
                ID       = "KB{0}" -f ($update.id).Split(":")[2]
                Updated  = ([DateTime]::Parse($update.updated))
            }
            $sortedUpdateList.Add($PSObject) | Out-Null
        }
        $latestUpdate = $sortedUpdateList | Sort-Object -Property Updated -Descending | Select-Object -First 1
    }

    # Return object to the pipeline
    Write-Output -InputObject $latestUpdate
}
