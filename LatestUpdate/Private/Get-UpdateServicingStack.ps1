Function Get-UpdateServicingStack {
    <#
        .SYNOPSIS
            Builds an object with the Servicing Stack Update.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Xml.XmlNode] $UpdateFeed,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version
    )

    # Filter object matching desired update type
    $updateList = New-Object -TypeName System.Collections.ArrayList
    ForEach ($item in $UpdateFeed.feed.entry) {
        If (($item.title -match $script:resourceStrings.SearchStrings.ServicingStack) -and ($item.title -match ".*$($Version).*")) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): matched item [$($item.title)]"
            $PSObject = [PSCustomObject] @{
                Title   = $item.title
                ID      = $item.id
                Version = $Version
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
        $latestUpdate = $sortedUpdateList | Sort-Object -Property Updated -Descending | Select-Object -First 1
        Write-Verbose -Message "$($MyInvocation.MyCommand): selected item [$($latestUpdate.title)]"
    }

    # Return object to the pipeline
    Write-Output -InputObject $latestUpdate
}
