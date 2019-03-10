Function New-MdtPackagesFolder {
    <#
    .SYNOPSIS
        Creates a folder in the MDT Packages node.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    
    .PARAMETER Drive
        An existing PS drive letter mapped to an MDT deployment share.

    .PARAMETER Path
        A new folder to create below the Packages node in the MDT deployment share.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [String] $Drive,

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String] $Path
    )

    # If $Path does not exist, attempt to create it
    If (!(Test-Path -Path "$($Drive):\Packages\$Path" -Type 'Container')) {
        If ($pscmdlet.ShouldProcess("$($Drive):\Packages\$Path", "Creating")) {
            Write-Verbose "Creating folder $($Drive):\Packages\$($Path)."
            Try {
                New-Item -Path "$($Drive):\Packages" -Enable "True" -Name $Path `
                    -Comments "Created by 'New-MdtPackagesFolder'" `
                    -ItemType "Folder"
            }
            Catch {
                Throw "Failed to create Packages folder."
            }

            # Return status from New-Item
            Write-Output $?
        }
    }
    Else {
        Write-Verbose "Path exists: $($Drive):\Packages\$Path"
    }
}
