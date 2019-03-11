Function Remove-MdtPackage {
    <#
    .SYNOPSIS
        Removes all packages from a specified path.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    
    .PARAMETER Path
        Target path that the packages will be removed from.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String] $Path
    )

    # Change to the target path
    Push-Location $Path

    # If change path is successful
    If ($?) {
        # Get packages from the current folder
        $packages = Get-ChildItem | Where-Object { $_.Name -like "Package*" } 

        # Step through each package and remove it
        ForEach ($package in $packages) {
            If ($pscmdlet.ShouldProcess($package.Name, "Remove package")) {
                Try {
                    # Remove, but don't force in case the update exists in another folder
                    Write-Verbose -Message "Removing package $($package.Name)"
                    Remove-Item -Path ".\$($package.Name)"
                }
                Catch {
                    Write-Error "Failed to remove item $($package.Name)"
                }
            }
        }

        # Change back to the original location
        Pop-Location
    }
}
