Function New-MdtDrive {
    <#
    .SYNOPSIS
        Creates a new persistent PS drive mapped to an MDT share.

    .DESCRIPTION
        Creates a new persistent PS drive mapped to an MDT share.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String]$Path,

        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)]
        [String]$Drive = "DS009"
    )
    $Description = "MDT drive created by $($MyInvocation.MyCommand)"
    If ($MdtDrives = Get-MdtPersistentDrive | Where-Object { ($_.Path -eq $Path) -and ($_.Description -eq $Description) }) {
        Write-Verbose "Found MDT drive: $($MdtDrives[0].Name)"
        $Output = $MdtDrives[0].Name
    } Else {
        If ($pscmdlet.ShouldProcess("$($Drive): to $($Path)", "Mapping")) {
            New-PSDrive -Name $Drive -PSProvider "MDTProvider" -Root $Path `
                -NetworkPath $Path -Description $Description | Add-MDTPersistentDrive
            $PsDrive = Get-MdtPersistentDrive | Where-Object { ($_.Path -eq $Path) -and ($_.Name -eq $Drive) }
            Write-Verbose "Found: $($PsDrive.Name)"
            $Output = $PsDrive.Name
        }
    }
    Write-Output $Output
}