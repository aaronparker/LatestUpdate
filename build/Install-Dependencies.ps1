Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'

Write-Host -Object "`nInstalling package providers:" -ForegroundColor 'Yellow'
$providerNames = 'NuGet', 'PowerShellGet'
foreach ( $providerName in $providerNames ) {
    if ( -not ( Get-PackageProvider $providerName -ErrorAction 'SilentlyContinue' ) ) {
        Install-PackageProvider -Name $providerName -Scope 'CurrentUser' -Force -ForceBootstrap
    }
}
Remove-Variable -Name 'providerName'

Get-PackageProvider -Name $providerNames |
    Format-Table -AutoSize -Property 'Name', 'Version'

Write-Host -Object "Installing modules:" -ForegroundColor 'Yellow'
$moduleNames = 'Pester', 'Coveralls', 'PSScriptAnalyzer'
foreach ( $moduleName in $moduleNames ) {
    if ( $env:APPVEYOR_BUILD_WORKER_IMAGE -eq 'WMF 5' ) {
        Install-Module -Name $moduleName -Scope 'CurrentUser' -Repository 'PSGallery' -Force -Confirm:$false |
            Out-Null
    }
    else {
        Install-Module -Name $moduleName -Scope 'CurrentUser' -Repository 'PSGallery' -SkipPublisherCheck -Force -Confirm:$false |
            Out-Null
    }
    
    Import-Module -Name $moduleName
}
Remove-Variable -Name 'moduleName'

Get-Module -Name $moduleNames |
    Format-Table -AutoSize -Property 'Name', 'Version'

Write-Host -Object ''
