Function Get-ValidPath {
    <#
    .SYNOPSIS
        Test a file system path and return correct path string.

    .DESCRIPTION
        Test a file system path and return correct path string.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$Path
    )
    $Output = ((Get-Item $Path).FullName).TrimEnd("\")
    Write-Output $Output
}