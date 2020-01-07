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
        [System.String] $Build,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Previous
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
                ID       = "KB{0}" -f ($item.id).Split(":")[2]
                Build   = $BuildVersion
                Revision = ($BuildVersion.Split(".")[1])
                Updated = $item.updated
            }
            $updateList.Add($PSObject) | Out-Null
        }
    }
    $Skip = 0
    if($Previous.IsPresent)
    {
        Write-Verbose -Message "$($MyInvocation.MyCommand): selecting previous update"
        $Skip = 1
    }
    $latestUpdate = $updateList | Sort-Object -Property Revision -Descending | Select-Object -First 1 -Skip $Skip
    Write-Verbose -Message "$($MyInvocation.MyCommand): selected item [$($latestUpdate.title)]"

    # Return object to the pipeline
    Write-Output -InputObject $latestUpdate
}
