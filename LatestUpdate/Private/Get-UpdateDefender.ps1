Function Get-UpdateDefender {
    <#
        .SYNOPSIS
            Builds an object with the update for Windows Defender antimalware platform.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Xml.XmlNode] $UpdateFeed
    )

    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    # Filter object matching desired update type
    $updateList = New-Object -TypeName System.Collections.ArrayList
    ForEach ($item in $UpdateFeed.feed.entry) {
        If ($item.title -match $resourceStrings.SearchStrings.WindowsDefender) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): matched item [$($item.title)]"
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
                Title   = $update.title
                ID      = "KB{0}" -f ($update.id).Split(":")[2]
                Updated = ([DateTime]::Parse($update.updated))
            }
            $sortedUpdateList.Add($PSObject) | Out-Null
        }
        $latestUpdate = $sortedUpdateList | Sort-Object -Property Updated -Descending
    }

    # Return object to the pipeline
    Write-Output -InputObject $latestUpdate
}
