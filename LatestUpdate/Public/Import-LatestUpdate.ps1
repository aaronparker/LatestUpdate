Function Import-LatestUpdate {
    <#
    .SYNOPSIS
        Imports the latest Windows packages into an MDT deployment share.

    .DESCRIPTION
        This function will import packages into an MDT Deployment Share. Retrieve the latest Cumulative updates for Windows 10 and Windows Server 2016 gathered by Get-LatestUpdate and downloaded with Save-LatestUpdate

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        http://stealthpuppy.com

    .PARAMETER UpdatePath
        The folder containing the updates to import into the MDT deployment share.

    .PARAMETER DeployRoot
        Specify the path to the MDT deployment share.

    .PARAMETER PackagePath
        A packges folder to import into relative to the Packages folder in the MDT share.

    .PARAMETER Clean
        Before importing the latest updates into the target path, remove any existing update package.

    .EXAMPLE
        Get-LatestUpdate | Save-LatestUpdate -Path "C:\Temp\Updates"
        Import-LatestUpdate -UpdatePath "C:\Temp\Updates" -DeployRoot "\\server\reference" -PackagePath "Windows 10"
        
        Description:
        Import the latest update gathered from Get-LatestUpdate into the deployment share \\server\reference under 'Packages\Windows 10'.

    .EXAMPLE
        Import-LatestUpdate -UpdatePath "C:\Temp\Updates" -DeployRoot "\\server\reference" -PackagePath "Windows 10" -Clean
        
        Description:
        Import the update stored in C:\Temp\Updates into the deployment share \\server\reference under 'Packages\Windows 10'. Any existing packages will be removed before the import.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $False, ValueFromPipeline = $True, `
                HelpMessage = "Specify the folder containing the MSU update/s to import.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [String] $UpdatePath = $PWD,

        [Parameter(Mandatory = $True, HelpMessage = "Specify an MDT deployment share to apply the update to.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [String] $DeployRoot,

        [Parameter(Mandatory = $False, HelpMessage = "A sub-folder in the MDT Packages folder.")]
        [String] $PackagePath,

        [Parameter(Mandatory = $False, `
                HelpMessage = "Remove the updates from the target MDT deployment share before importing the new updates.")]
        [Switch] $Clean
    )
    Begin {
        # If running on PowerShell Core, error and exit.
        If (Test-PSCore) {
            Write-Error -Message "PowerShell Core doesn't support PSSnapins. We can't load the MicrosoftDeploymentToolkit module." -ErrorAction Stop
            Break
        }

        If (Import-MdtModule) {
            If ($pscmdlet.ShouldProcess($Path, "Mapping")) {
                [String] $drive = "DS004"
                $drive = New-PSDrive -Name $drive -PSProvider MDTProvider -Root $DeployRoot
            }
        }
        Else {
            Write-Error -Message "Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again." -ErrorAction Stop
        }
        # Ensure file system paths are valid and don't include trailing \
        $UpdatePath = Get-ValidPath $UpdatePath
    }
    Process {
        # If $PackagePath is specified, use a sub-folder of MDT Share\Packages
        If ($PSBoundParameters.ContainsKey('PackagePath')) {
            $dest = "$($drive):\Packages\$($PackagePath)"
            If ($pscmdlet.ShouldProcess($PackagePath, "New Package Folder")) {
                Try {
                    New-MdtPackagesFolder -Drive $drive -Path $PackagePath
                }
                Catch {
                    Write-Error -Message "Failed to create packages folder $($PackagePath)." -ErrorAction Stop
                }
            }
        }
        Else {
            # If no path specified, we'll import directly into the Packages folder
            $dest = "$($drive):\Packages"
        }
        Write-Verbose "Destination is $($dest)"

        # If -Clean is specified, enumerate existing packages from the target destination and remove before importing
        If ($Clean) {
            Push-Location $dest
            Get-ChildItem | Where-Object { $_.Name -like "Package*" } | ForEach-Object { 
                If ( $pscmdlet.ShouldProcess($_.Name, "Remove package") ) {
                    # Remove, but don't force in case the update exists in another folder
                    Remove-Item $_.Name
                }
            }
            Pop-Location
        }

        # Validate the provided local path and import the update package
        If ($UpdatePath -ne $False) {
            If ($pscmdlet.ShouldProcess("From $($UpdatePath) to $($dest)", "Importing")) {
                Try {
                    Import-MdtPackage -Path $dest -SourcePath $UpdatePath -ErrorAction SilentlyContinue -ErrorVariable importError
                }
                Catch {
                    Write-Error -Message "Failed to import the package."
                }
            }
        }
        Else {
            Write-Error -Message "Validation failed on the provided path $UpdatePath" -ErrorAction Stop
        }
    }
    End {
        If ($importError) { Write-Output $importError }
    }
}
