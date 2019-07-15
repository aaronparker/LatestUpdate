Function Get-UpdateCumulative {
    <#
        .SYNOPSIS
            Builds an object with the Cumulative Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Xml.XmlNode] $UpdateFeed,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Build
    )

    # Filter object matching desired update type
    [regex] $rxB = "$Build.(\d+)"
    $updateList = New-Object -TypeName System.Collections.ArrayList
    ForEach ($item in $UpdateFeed.feed.entry) {
        If ($item.title -match $rxB) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): matched item [$($item.title)]"
            $BuildVersion = [regex]::Match($item.title, $rxB).Value
            $PSObject = [PSCustomObject] @{
                Title   = $item.title
                ID      = $item.id
                Build   = $BuildVersion
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
                Build    = $update.Build.Split(".")[0]
                Revision = [int]($update.Build.Split(".")[1])
                Updated  = ([DateTime]::Parse($update.updated))
            }
            $sortedUpdateList.Add($PSObject) | Out-Null
        }
        $latestUpdate = $sortedUpdateList | Sort-Object -Property Revision -Descending | Select-Object -First 1
        Write-Verbose -Message "$($MyInvocation.MyCommand): selected item [$($latestUpdate.title)]"
    }

    # Return object to the pipeline
    Write-Output -InputObject $latestUpdate
}
