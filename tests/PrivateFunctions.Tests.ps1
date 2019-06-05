# Pester tests
# Set variables
If ($Null -eq $projectRoot) {
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = "LatestUpdate"
}
Import-Module (Join-Path $projectRoot $module) -Force
If (Get-Variable -Name APPVEYOR_BUILD_FOLDER -ErrorAction SilentlyContinue) {
    $moduleParent = Join-Path $env:APPVEYOR_BUILD_FOLDER $module
    $manifestPath = Join-Path $moduleParent "$module.psd1"
    $modulePath = Join-Path $moduleParent "$module.psm1"
    $modulePrivate = Join-Path $moduleParent "Private"
    $modulePublic = Join-Path $moduleParent "Public"
}

InModuleScope LatestUpdate {
    Describe 'Test-PSCore' {
        $Version = '6.0.0'
        Context "Tests whether we are running on PowerShell Core" {
            It "Imports the MDT PowerShell module and returns True" {
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

    Describe 'Get-UpdateFeed' {
        . (Join-Path $modulePrivate "Get-ModuleString.ps1")
        . (Join-Path $modulePrivate "Get-UpdateFeed.ps1")
        $strings = Get-ModuleString
        $updateFeed = Get-UpdateFeed -Uri $strings.UpdateFeeds.Windows10
        Context "Tests that Get-UpdateFeed returns valid XML" {
            It "Returns valid XML" {
                $updateFeed | Should -BeOfType System.Xml.XmlNode
            }
        }
    }

    Describe 'Get-UpdateCatalogLink' {
        $kbObj = Get-UpdateCatalogLink -KB "4483235"
        Context "Tests that Get-UpdateCatalogLink returns valid response" {
            It "Returns valid response" {
                $kbObj | Should -BeOfType Microsoft.PowerShell.Commands.WebResponseObject
            }
        }
    }

    Describe 'Get-KbUpdateArray' {
        $kbObj = Get-UpdateCatalogLink -KB "4483235"
        $idTable = Get-KbUpdateArray -Links $kbObj.Links -KB "4483235"
        Context "Tests that Get-KbUpdateArray returns a valid array" {
            It "Returns a valid array" {
                $idTable | Should -BeOfType PSCustomObject
            }
            It "Returns an array with valid properties" {
                ForEach ($id in $idTable) {
                    $id.KB.Length | Should -BeGreaterThan 0
                    $id.Id.Length | Should -BeGreaterThan 0
                    $id.Note.Length | Should -BeGreaterThan 0
                }
            }
        }
    }

    Describe 'Get-UpdateDownloadArray' {
        $kbObj = Get-UpdateCatalogLink -KB "4483235"
        $idTable = Get-KbUpdateArray -Links $kbObj.Links -KB "4483235"
        $Updates = Get-UpdateDownloadArray -IdTable $idTable
        Context "Returns a valid list of Cumulative updates" {
            It "Updates array returned Should -Be of valid type" {
                $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
            }
            It "Updtes array returned should have a count greater than 0" {
                $Updates.Count | Should -BeGreaterThan 0
            }
            It "Returns a valid array with expected properties" {
                ForEach ($Update in $Updates) {
                    $Update.KB.Length | Should -BeGreaterThan 0
                    $Update.Arch.Length | Should -BeGreaterThan 0
                    $Update.Note.Length | Should -BeGreaterThan 0
                    $Update.URL.Length | Should -BeGreaterThan 0
                }
            }
        }
    }
}
