Function Get-RxString {
    <#
        .SYNOPSIS
            Return matching sub-string from a supplied string..

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER String
            A string to search.

        .PARAMETER RegEx
            A regular expression to match.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param (
        [Parameter()]
        [string] $String,

        [Parameter()]
        [RegEx] $RegEx
    )

    $String -match $RegEx > $Null
    Write-Output $Matches[1]

    # [regex]::match($String, $RegEx).Groups[1].Value
}
