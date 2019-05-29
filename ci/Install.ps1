<#
    .SYNOPSIS
        AppVeyor install script.
#>
# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}

# Line break for readability in AppVeyor console
Write-Host -Object ''
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.tostring()

# Install packages
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Pester -SkipPublisherCheck -Force
Install-Module -Name PSScriptAnalyzer -SkipPublisherCheck -Force
Install-Module -Name posh-git -Force

# Set variables
$module = $env:Module
$tests = Join-Path $projectRoot "tests"
$output = Join-Path $projectRoot "TestsResults.xml"

# Echo variables
Write-Host -Object ''
Write-Host "ProjectRoot: $projectRoot."
Write-Host "Module name: $module."
Write-Host "Tests path:  $tests."
Write-Host "Output path: $output."

# Import module
Write-Host -Object ''
Import-Module (Join-Path $projectRoot $module) -Verbose -Force
