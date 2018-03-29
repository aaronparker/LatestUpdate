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
         .\Get-LatestUpdate.ps1 -Download -Path C:\Updates | .\Import-LatestUpdate.ps1 -SharePath \\server\reference -PackagePath 'Windows 10'
        
        Import the latest update gathered from Get-LatestUpdate.ps1 into the deployment share \\server\reference under 'Packages\Windows 10'.

    .EXAMPLE
         .\Import-LatestUpdate.ps1 -UpdatePath C:\Updates -SharePath \\server\reference -Clean -Verbose
        
        Import the latest update stored in C:\Updates into the deployment share \\server\reference. Remove all existing packages first. Show verbose output.

    .EXAMPLE
         .\Import-LatestUpdate.ps1 -UpdatePath C:\Updates -SharePath \\server\reference -PackagePath 'Windows 10'
        
        Import the latest update stored in C:\Updates into the deployment share \\server\reference under 'Packages\Windows 10'.
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

        # Fix $UpdatePath to ensure it's valid for Import-MdtPackage
        $UpdatePath = Test-UpdateParameter (Get-Item $UpdatePath).FullName
    }
    Process {

        # If $PackagePath is specified, use a sub-folder of MDT Share\Packages
        If ($PSBoundParameters.ContainsKey('PackagePath')) {
            $Dest = New-MdtPackagesFolder -Drive $Drive -Path $PackagePath
        }
        Else {
            # If no path specified, we'll import directly into the Packages folder
            $Dest = "$($Drive):\Packages"
        }
        Write-Verbose "About to import into: $Dest"

        # If we could create the path successfully, or import directly into \Packges, continue
        If ($Dest -ne $False) {

            # If -Clean is specified, enumerate existing packages from the target destination and remove before importing
            If ($Clean) {
                Write-Verbose "Removing existing update packages."
                Push-Location $Dest
                # Get Package items from the target folder, and remove them
                # If they appear in other folders we won't remove copies
                Get-ChildItem | Where-Object { $_.Name -like "Package*" } | ForEach-Object { Remove-Item $_.Name }
                Pop-Location
            }

            # Validate the provided local path and import the update package
            If ($UpdatePath -ne $False) {
                Write-Verbose "Importing from $($UpdatePath)"
                Import-MdtPackage -Path $Dest -SourcePath $UpdatePath
            }
            Else {
                Write-Error "Validation failed on the provided path $Update"
            }
        }
    }
    End {
    }
}