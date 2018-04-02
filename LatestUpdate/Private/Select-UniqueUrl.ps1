Function Select-UniqueUrl {
    <#
    .SYNOPSIS
        Selects unique URLs from the array of updates returned from Get-LatestUpdate.

    .DESCRIPTION
        Selects unique URLs from the array of updates returned from Get-LatestUpdate.
        Multiple updates can be release which could point to the same URL. To ensure we only download the update once,
        the a unique URL needs to be passed back to Save-LatestUpdate.

    .PARAMETER Updates
        An array of updates retrieved by Get-LatestUpdate.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .PARAMETER Updates
        The array of latest cumulative updates retreived by Get-LatestUpdate.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([Array])]
    Param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, `
                HelpMessage = "The array of updates from Get-LatestUpdate.")]
        [ValidateNotNullOrEmpty()]
        [Array] $Updates    
    )
    $urls = @()
    ForEach ( $update in $Updates ) {
        $urls += $update.Url
    }
    $urls = $urls | Select-Object -Unique
    $urls
}
