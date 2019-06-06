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
}

Describe 'Get-LatestCumulativeUpdate' {
    Context "Returns a valid list of Cumulative updates" {
        $Updates = Get-LatestCumulativeUpdate
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Windows 10: Returns expected results for each version" {
        It "Given '1903' returns updates for build 1903" {
            $Updates = Get-LatestCumulativeUpdate
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1903" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1903" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '1809' returns updates for build 1809" {
            $Updates = Get-LatestCumulativeUpdate -Version '1809'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1809" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1809" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '1803' returns updates for build 1803" {
            $Updates = Get-LatestCumulativeUpdate -Version '1803'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1803" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1803" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '1709' returns updates for build 1709" {
            $Updates = Get-LatestCumulativeUpdate -Version '1709'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1709" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1709" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '1703' returns updates for build 1703" {
            $Updates = Get-LatestCumulativeUpdate -Version '1703'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1703" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1703" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '1607' returns updates for build 1607" {
            $Updates = Get-LatestCumulativeUpdate -Version '1607'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1607" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1607" | Should -Not -BeNullOrEmpty
            }
        }
    }

}

Describe 'Get-LatestAdobeFlashUpdate' {
    $Updates = Get-LatestAdobeFlashUpdate
    Context "Returns a valid list of Adobe Flash Player updates" {
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results with Flash updates array" {
        It "Given no arguments, returns updates for Adobe Flash Player" {
            ForEach ($Update in $Updates) {
                $Update.Note -match ".*Adobe Flash Player.*" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Get-LatestServicingStack' {
    $Updates = Get-LatestServicingStack
    Context "Returns a valid list of Servicing Stack updates" {
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results with Servicing Stack updates array" {
        It "Given no arguments, returns updates for Servicing Stack" {
            ForEach ($Update in $Updates) {
                $Update.Note -match "Servicing stack update.*" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1607|1703|1709|1803|1809|1903" | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Get-LatestNetFrameworkUpdate' {
    $Updates = Get-LatestNetFrameworkUpdate
    Context "Returns a valid cumulative .NET Framework update" {
        It "Given an OS as argument, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results with .NET Framework updates array" {
        It "Given an OS as argument, returns an cumulative update for .NET Framework" {
            ForEach ($Update in $Updates) {
                $Update.Note -match ".*Cumulative Update for .NET Framework.*" | Should -Not -BeNullOrEmpty
            }
        }
    }
}

If (Test-Path -Path 'env:APPVEYOR_BUILD_FOLDER') {
    # Skip download tests unless running in AppVeyor.
    
    Describe 'Save-LatestUpdate' {
        Context "Download the latest Windows 10 Cumulative updates" {
            $Updates = Get-LatestCumulativeUpdate
            $Target = $env:TEMP
            Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest -Verbose
            It "Given updates returned from Get-LatestCumulativeUpdate, it successfully downloads the update" {
                ForEach ($Update in $Updates) {
                    $Filename = Split-Path $Update.Url -Leaf
                    Write-Host "Check for $(Join-Path $Target $Filename)."
                    (Join-Path $Target $Filename) | Should -Exist
                }
            }
        }
        Context "Download the latest Adobe Flash Player updates" {
            $Updates = Get-LatestAdobeFlash
            $Target = $env:TEMP
            Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest -Verbose
            It "Given updates returned from Get-LatestAdobeFlash, it successfully downloads the update" {
                ForEach ($Update in $Updates) {
                    $Filename = Split-Path $Update.URL -Leaf
                    Write-Host "Check for $(Join-Path $Target $Filename)."
                    (Join-Path $Target $Filename) | Should -Exist
                }
            }
        }
        Context "Download the latest Servicing Stack updates" {
            $Updates = Get-LatestServicingStack
            $Target = $env:TEMP
            Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest -Verbose
            It "Given updates returned from Get-LatestServicingStack, it successfully downloads the update" {
                ForEach ($Update in $Updates) {
                    $Filename = Split-Path $Update.URL -Leaf
                    Write-Host "Check for $(Join-Path $Target $Filename)."
                    (Join-Path $Target $Filename) | Should -Exist
                }
            }
        }
    }
}
