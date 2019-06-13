<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
Param ()

# Set variables
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = "LatestUpdate"
}
Import-Module (Join-Path $projectRoot $module) -Force

InModuleScope LatestUpdate {
    Describe 'Test-PSCore' {
        $Version = '6.0.0'
        Context "Tests whether we are running on PowerShell Core" {
            It "Returns True if running Windows PowerShell" {
                If (($PSVersionTable.PSVersion -ge [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Core")) {
                    Test-PSCore | Should -Be $True
                }
            }
        }
        Context "Tests whether we are running on Windows PowerShell" {
            It "Returns False if running Windows PowerShell" {
                If (($PSVersionTable.PSVersion -lt [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Desktop")) {
                    Test-PSCore | Should -Be $False
                }
            }
        }
    }

    <#
    Describe 'Get-UpdateFeed' {
        . (Join-Path $modulePrivate "Get-ModuleResource.ps1")
        . (Join-Path $modulePrivate "Get-UpdateFeed.ps1")
        $Path = Join-Path $moduleParent "LatestUpdate.json"
        Write-Host "JSON path: $Path."
        $resourceStrings = Get-ModuleResource -Path $Path
        $updateFeed = Get-UpdateFeed -Uri $resourceStrings.UpdateFeeds.Windows10
        Context "Tests that Get-UpdateFeed returns valid XML" {
            It "Returns valid XML" {
                $updateFeed | Should -BeOfType System.Xml.XmlNode
            }
        }
    }
    #>
}
