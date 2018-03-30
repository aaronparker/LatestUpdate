Function Import-LatestUpdate {
    <#
    .SYNOPSIS
        Imports the latest Windows update into MDT.

    .DESCRIPTION
        This script will import the latest Cumulative updates for Windows 10 and Windows Server 2016 gathered by Get-LatestUpdate.ps1 into an MDT deployment share.

    .NOTES
        Name: Import-Update
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        http://stealthpuppy.com

    .PARAMETER UpdatePath
        The folder containing the updates to import into the MDT deployment share.

    .PARAMETER PathPath
        Specify the path to the MDT deployment share.

    .PARAMETER PackagePath
        A packges folder to import into relative to the Packages folder in the MDT share.

    .PARAMETER Clean
        Before importing the latest updates into the target path, remove any existing update package.

    .EXAMPLE
        $Updates = Get-LatestUpdate
        Save-LatestUpdate -Updates $Updates -Path "C:\Temp\Updates" -Verbose
        Import-LatestUpdate -UpdatePath "C:\Temp\Updates" -SharePath "\\server\reference" -PackagePath "Windows 10"
        
        Description:
        Import the latest update gathered from Get-LatestUpdate into the deployment share \\server\reference under 'Packages\Windows 10'.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, `
                HelpMessage = "Specify the folder containing the MSU update/s to import.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$UpdatePath,

        [Parameter(Mandatory = $True, HelpMessage = "Specify an MDT deployment share to apply the update to.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$SharePath,

        [Parameter(Mandatory = $False, HelpMessage = "A sub-folder in the MDT Packages folder.")]
        [string]$PackagePath,

        [Parameter(Mandatory = $False, `
                HelpMessage = "Remove the updates from the target MDT deployment share before importing the new updates.")]
        [switch]$Clean
    )
    Begin {
        $Drive = "DS001"
        If (Import-MdtModule) {
            If ($pscmdlet.ShouldProcess("$($Drive): to $($Path)", "Mapping")) {
                If (Test-Path "$($Drive):") {
                    Write-Verbose "Found existing MDT drive $Drive."
                    Remove-PSDrive -Name $Drive -Force
                }
                $Drive = New-PSDrive -Name $Drive -PSProvider MDTProvider -Root $SharePath
            }
        }
        Else {
            Write-Error -Message "Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again." -ErrorAction Stop
        }

        # Ensure file system paths are valid and don't include trailing \
        $UpdatePath = Get-ValidPath $UpdatePath
        $SharePath = Get-ValidPath $SharePath
    }
    Process {
        # If $PackagePath is specified, use a sub-folder of MDT Share\Packages
        If ($PSBoundParameters.ContainsKey('PackagePath')) {
            $Dest = "$($Drive):\Packages\$($PackagePath)"
            If ($pscmdlet.ShouldProcess($PackagePath, "New Package Folder")) {
                Try {
                    $Dest = New-MdtPackagesFolder -Drive $Drive -Path $PackagePath
                }
                Catch {
                    Write-Error -Message "Failed to create packages folder $($PackagePath)." -ErrorAction Stop
                }
            }
        }
        Else {
            # If no path specified, we'll import directly into the Packages folder
            $Dest = "$($Drive):\Packages"
        }

        # If -Clean is specified, enumerate existing packages from the target destination and remove before importing
        If ($Clean) {
            Push-Location $Dest
            Get-ChildItem | Where-Object { $_.Name -like "Package*" } | ForEach-Object { 
                If ($pscmdlet.ShouldProcess($_.Name, "Remove package")) {
                    # Remove, but don't force in case the update exists in another folder
                    Remove-Item $_.Name
                }
            }
            Pop-Location
        }

        # Validate the provided local path and import the update package
        If ($UpdatePath -ne $False) {
            If ($pscmdlet.ShouldProcess("From $($UpdatePath) to $($Dest)", "Importing")) {
                Import-MdtPackage -Path $Dest -SourcePath $UpdatePath
            }
        }
        Else {
            Write-Error "Validation failed on the provided path $Update"
        }
    }
    End {
    }
}