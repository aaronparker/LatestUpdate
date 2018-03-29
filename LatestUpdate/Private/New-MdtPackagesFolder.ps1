Function New-MdtPackagesFolder {
    <#
    .SYNOPSIS
        Creates a folder in the MDT Packages node.

    .DESCRIPTION
        Creates a folder in the MDT Packages node.

    .NOTES

    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [String]$Drive,

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String]$Path
    )
    [String]$Dest = "$($Drive):\Packages\$Path"
    If (!(Test-Path -Path $Dest -Type 'Container')) {
        If ($pscmdlet.ShouldProcess("$($Drive):\Packages\$Path", "Creating")) {
            Write-Verbose "Creating folder $Dest."
            Push-Location "$($Drive):\Packages"
            New-Item -Path "$($Drive):\Packages" -Enable "True" -Name $Path `
                -Comments "Created by 'New-MdtPackagesFolder'" `
                -ItemType "Folder"
            Pop-Location
        }
    }
    Return $Dest
}