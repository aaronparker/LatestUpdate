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
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [ValidateNotNull()]
        [string] $String,

        [Parameter(Mandatory = $True, Position = 1)]
        [RegEx] $RegEx
    )

    # Extract sub-string from $String via the RegEx and return on the pipeline
    $String -match $RegEx > $Null
    If ($Null -ne $Matches[1]) {
        Write-Output $Matches[1]
    }

    # Alternative method for extracting sub-string
    # [regex]::match($String, $RegEx).Groups[1].Value
}
