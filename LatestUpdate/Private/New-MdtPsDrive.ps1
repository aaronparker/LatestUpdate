Function New-MdtPsDrive {
    <#
    .SYNOPSIS
        Creates a new PS drive mapped to an MDT share.

    .DESCRIPTION
        Creates a new PS drive mapped to an MDT share.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)]
        [String]$Drive = "DS001",

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String]$Path
    )
    $Drive = "DS001"
    If ($pscmdlet.ShouldProcess("$($Drive): to $($Path)", "Mapping")) {
        If (Test-Path "$($Drive):") {
            Write-Verbose "Found existing MDT drive $Drive."
            Remove-PSDrive -Name $Drive -Force
        }
        $Drive = New-PSDrive -Name $Drive -PSProvider MDTProvider -Root $Path
    }
    Write-Output $Drive.Name
}