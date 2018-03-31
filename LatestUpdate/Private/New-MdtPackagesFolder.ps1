Function New-MdtPackagesFolder {
    <#
    .SYNOPSIS
        Creates a folder in the MDT Packages node.

    .DESCRIPTION
        Creates a folder in the MDT Packages node.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [String]$Drive,

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String]$Path
    )
    If ((Test-Path -Path "$($Drive):\Packages\$Path" -Type 'Container')) {
        Write-Output $True
    } Else {
        If ($pscmdlet.ShouldProcess("$($Drive):\Packages\$Path", "Creating")) {
            Write-Verbose "Creating folder $($Drive):\Packages\$($Path)."
            # Push-Location "$($Drive):\Packages"
            Try {
                New-Item -Path "$($Drive):\Packages" -Enable "True" -Name $Path `
                -Comments "Created by 'New-MdtPackagesFolder'" `
                -ItemType "Folder"
            }
            Catch {
                Throw "Failed to create Packages folder."
            }
            Write-Output $?
        }
    }
}