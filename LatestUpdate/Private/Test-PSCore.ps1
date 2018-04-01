Function Test-PSCore {
    <#
    .SYNOPSIS
        Returns True is running on PowerShell Core.

    .DESCRIPTION
        Returns True is running on PowerShell Core.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param (
        [Parameter(ValueFromPipeline)]
        [string]$Version = '6.0.0'
    )
    If (($PSVersionTable.PSVersion -ge [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Core")) {
        Write-Output $True
    }
    Else {
        Write-Output $False
    }
}