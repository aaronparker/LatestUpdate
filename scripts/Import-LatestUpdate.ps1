#Requires -PSEdition Desktop
<#
    .SYNOPSIS
        Imports the latest Windows packages into an MDT deployment share.

    .DESCRIPTION
        This script will download Windows 10 updates and import the packages into an MDT deployment share.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://docs.stealthpuppy.com/docs/latestupdate

    .PARAMETER UpdatePath
        The folder containing the updates to import into the MDT deployment share.

    .PARAMETER DeployRoot
        Specify the path to the MDT deployment share.

    .PARAMETER PackagePath
        A packges folder to import into relative to the Packages folder in the MDT share.

    .PARAMETER Clean
        Before importing the latest updates into the target path, remove any existing update package.

    .EXAMPLE
        Import-LatestUpdate -UpdatePath "C:\Temp\Updates" -DeployRoot "\\server\reference" -PackagePath "Windows 10"
        
        Description:
        Download and import the latest updates into the deployment share \\server\reference under 'Packages\Windows 10'.
    #>
[CmdletBinding(SupportsShouldProcess = $False)]
Param (
    [Parameter(Mandatory = $False, HelpMessage = "Specify the folder containing the MSU update/s to import.")]
    [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
    [ValidateNotNullOrEmpty()]
    [System.String] $UpdatePath = $PWD,
    
    [Parameter(Mandatory = $True, HelpMessage = "Specify an MDT deployment share to apply the update to.")]
    [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
    [ValidateNotNullOrEmpty()]
    [System.String] $DeployRoot,
    
    [Parameter(Mandatory = $False, HelpMessage = "A sub-folder in the MDT Packages folder.")]
    [ValidateNotNullOrEmpty()]
    [System.String] $PackagePath,
    
    [Parameter(Mandatory = $False, HelpMessage = "Remove the updates from the target MDT deployment share before importing the new updates.")]
    [System.Management.Automation.SwitchParameter] $Clean,

    [Parameter(Mandatory = $False)]
    [System.String] $Version = "1903",

    [Parameter(Mandatory = $False)]
    [System.String] $Architecture = "x64",

    [Parameter(Mandatory = $False)]
    [System.String] $Drive = "DS004"
)

# Import MDT module and mount deployment share
$InstallDir = Resolve-Path -Path $((Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4" -ErrorAction SilentlyContinue).Install_Dir)
$MdtPath = Join-Path -Path $InstallDir -ChildPath "bin"
$MdtModule = Resolve-Path -Path (Join-Path -Path $MdtPath -ChildPath "MicrosoftDeploymentToolkit.psd1")
Try {            
    Import-Module -Name $MdtModule -ErrorAction SilentlyContinue
}
Catch {
    Throw "Could not load MDT PowerShell Module. Please make sure that the MDT Workbench is installed correctly."
    Exit
}
$Drive = New-PSDrive -Name $Drive -PSProvider MDTProvider -Root $DeployRoot

# If $PackagePath is specified, use a sub-folder of MDT Share\Packages
If ($PSBoundParameters.ContainsKey('PackagePath')) {
    $Dest = "$($Drive):\Packages\$($PackagePath)"
    Try {
        New-MdtPackagesFolder -Drive $Drive -Path $PackagePath -ErrorAction SilentlyContinue
    }
    Catch {
        Write-Warning -Message "Failed to create packages folder [$($Drive):\Packages\$($PackagePath)]"
    }
}
Else {
    # If no path specified, we'll import directly into the Packages folder
    $Dest = "$($Drive):\Packages"
}
Write-Host "Destination is: [$($Dest)]"
    
# If -Clean is specified, remove packages from the destination folder
If ($Clean) {
    Write-Host "Cleaning: [$Dest]" -ForegroundColor Cyan
    Remove-MdtPackage -Path $Dest -Verbose
}

# Ensure $UpdatePath exists
If (Test-Path -Path $UpdatePath) {
    Write-Host "Path exists: [$UpdatePath]" -ForegroundColor Cyan
}
Else {
    New-Item -Path $UpdatePath -ItemType Directory
}

# Download the updates
Write-Host "Downloading cumulative updates." -ForegroundColor Cyan
Get-LatestCumulativeUpdate -Version $Version | Where-Object { $_.Architecture -eq $Architecture } | Save-LatestUpdate -Path $UpdatePath -Method WebClient

Write-Host "Downloading servicing stack updates." -ForegroundColor Cyan
Get-LatestServicingStackUpdate -Version $Version  | Where-Object { $_.Architecture -eq $Architecture } | Save-LatestUpdate -Path $UpdatePath -Method WebClient

Write-Host "Downloading servicing stack updates." -ForegroundColor Cyan
Get-LatestAdobeFlashUpdate -Version $Version  | Where-Object { $_.Architecture -eq $Architecture } | Save-LatestUpdate -Path $UpdatePath -Method WebClient

# Write-Host "Downloading Windows Defender updates." -ForegroundColor Cyan
# Get-LatestWindowsDefenderUpdate | Save-LatestUpdate -Path $UpdatePath -Method WebClient

Write-Host "Downloading .NET Framework updates." -ForegroundColor Cyan
Get-LatestNetFrameworkUpdate | Where-Object { $_.Version -eq $Version } | Where-Object { $_.Architecture -eq $Architecture } | Save-LatestUpdate -Path $UpdatePath -Method WebClient


# Validate the provided local path and import the update package
If ($UpdatePath -ne $False) {
    Try {
        Import-MdtPackage -Path $Dest -SourcePath $UpdatePath -ErrorAction SilentlyContinue -Verbose
    }
    Catch {
        Write-Warning -Message "Failed to import the package."
    }
}
Else {
    Write-Warning -Message "Validation failed on the provided path: [$UpdatePath]" -ErrorAction Stop
}
