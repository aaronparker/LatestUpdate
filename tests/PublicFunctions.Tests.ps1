# Pester tests
# Set variables
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
}
If ($Null -eq $module ) { $module = "LatestUpdate" }
$moduleParent = Join-Path $projectRoot $module
$manifestPath = Join-Path $moduleParent "$module.psd1"
$modulePath = Join-Path $moduleParent "$module.psm1"
$modulePrivate = Join-Path $moduleParent "Private"
$modulePublic = Join-Path $moduleParent "Public"
Import-Module (Join-Path $projectRoot $module) -Force

Describe 'Get-LatestCumulativeUpdate' {
    $Updates = Get-LatestCumulativeUpdate
    Context "Returns a valid list of Cumulative updates" {
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns a valid array with expected properties: [$($Update.Version), $($Update.Architecture)]" {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results for each Windows 10 version" {
        $Updates = Get-LatestCumulativeUpdate
        ForEach ($Update in $Updates) {
            It "Given '1903' returns updates for version 1903: [$($Update.Version), $($Update.Architecture)]" {
                $Update.Note -match "Cumulative.*1903" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1903" | Should -Not -BeNullOrEmpty
            }
        }
        $Updates = Get-LatestCumulativeUpdate -Version '1809'
        ForEach ($Update in $Updates) {
            It "Given '1809' returns updates for version 1809: [$($Update.Version), $($Update.Architecture)]" {
                $Update.Note -match "Cumulative.*1809" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1809" | Should -Not -BeNullOrEmpty
            }
        }
        $Updates = Get-LatestCumulativeUpdate -Version '1803'
        ForEach ($Update in $Updates) {
            It "Given '1803' returns updates for version 1803: [$($Update.Version), $($Update.Architecture)]" {
                $Update.Note -match "Cumulative.*1803" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1803" | Should -Not -BeNullOrEmpty
            }
        }
        $Updates = Get-LatestCumulativeUpdate -Version '1709'
        ForEach ($Update in $Updates) {
            It "Given '1709' returns updates for version 1709: [$($Update.Version), $($Update.Architecture)]" {
                $Update.Note -match "Cumulative.*1709" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1709" | Should -Not -BeNullOrEmpty
            }
        }
        $Updates = Get-LatestCumulativeUpdate -Version '1703'
        ForEach ($Update in $Updates) {
            It "Given '1703' returns updates for version 1703: [$($Update.Version), $($Update.Architecture)]" {
                $Update.Note -match "Cumulative.*1703" | Should -Not -BeNullOrEmpty
                $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1703" | Should -Not -BeNullOrEmpty
            }
        }
        $Updates = Get-LatestCumulativeUpdate -Version '1607'
        ForEach ($Update in $Updates) {
            It "Given '1607' returns updates for version 1607: [$($Update.Version), $($Update.Architecture)]" {
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
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns a valid array with expected properties: [$($Update.Version), $($Update.Architecture)]" {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results with Flash updates array" {
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns updates for Adobe Flash Player: [$($Update.Version), $($Update.Architecture)]" {
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
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns a valid array with expected properties: [$($Update.Version), $($Update.Architecture)]" {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results with Servicing Stack updates array" {
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns updates for Servicing Stack: [$($Update.Version), $($Update.Architecture)]" {
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
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns a valid array with expected properties: [$($Update.Version), $($Update.Architecture)]" {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results with .NET Framework updates array" {
        ForEach ($Update in $Updates) {
            It "Returns a cumulative update for .NET Framework: [$($Update.Version), $($Update.Architecture)]" {
                $Update.Note -match ".*Cumulative Update for .NET Framework.*" | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Get-LatestMonthlyRollup' {
    $Updates = Get-LatestMonthlyRollup
    Context "Returns expected results with Monthly Rollup updates array" {
        ForEach ($Update in $Updates) {
            It "Returns a Monthly Rollup update: [$($Update.Version), $($Update.Architecture)]" {
                $Update.Note -match ".*Monthly Rollup.*" | Should -Not -BeNullOrEmpty
            }
        }
    }
    Context "Returns a valid Windows 8.1 monthly rollup update" {
        It "Given an OS as argument, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns a valid array with expected properties: [$($Update.Version), $($Update.Architecture)]" {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns a valid Windows 7 monthly rollup update" {
        $Updates = Get-LatestMonthlyRollup -Version 'Windows 7'
        It "Given an OS as argument, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns a valid array with expected properties: [$($Update.Version), $($Update.Architecture)]" {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Architecture.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
}

Describe 'Get-LatestWindowsDefenderUpdate' {
    $Updates = Get-LatestWindowsDefenderUpdate
    Context "Returns expected results with Windows Defender updates array" {
        ForEach ($Update in $Updates) {
            It "Returns a Windows Defender update" {
                $Update.Note -match ".*Monthly Rollup.*" | Should -Not -BeNullOrEmpty
            }
        }
    }
    Context "Returns a valid Windows Defender update" {
        It "Returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSObject
        }
        ForEach ($Update in $Updates) {
            It "Given no arguments, returns a valid array with expected properties" {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
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
            $Downloads = Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest
            ForEach ($Update in $Updates) {
                $Filename = Split-Path $Update.Url -Leaf
                It "Given updates returned from Get-LatestCumulativeUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                    (Join-Path $Target $Filename) | Should -Exist
                }
                It "Should match actual downloaded file and Get-LatestCumulativeUpdate output: [$($Update.Version), $($Update.Architecture)]" {
                    $Downloads.Target -contains (Join-Path $Target $Filename) | Should -Be $True
                }
            }
        }
        Context "Download the latest Adobe Flash Player updates" {
            $Updates = Get-LatestAdobeFlashUpdate
            $Target = $env:TEMP
            $Downloads = Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest
            ForEach ($Update in $Updates) {
                $Filename = Split-Path $Update.Url -Leaf
                It "Given updates returned from Get-LatestAdobeFlashUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                    (Join-Path $Target $Filename) | Should -Exist
                }
                It "Should match actual downloaded file and Get-LatestAdobeFlashUpdate output: [$($Update.Version), $($Update.Architecture)]" {
                    $Downloads.Target -contains (Join-Path $Target $Filename) | Should -Be $True
                }
            }
        }
        Context "Download the latest Servicing Stack updates" {
            $Updates = Get-LatestServicingStackUpdate
            $Target = $env:TEMP
            $Downloads = Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest
            ForEach ($Update in $Updates) {
                $Filename = Split-Path $Update.Url -Leaf
                It "Given updates returned from Get-LatestServicingStackUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                    (Join-Path $Target $Filename) | Should -Exist
                }
                It "Should match actual downloaded file and Get-LatestServicingStackUpdate output: [$($Update.Version), $($Update.Architecture)]" {
                    $Downloads.Target -contains (Join-Path $Target $Filename) | Should -Be $True
                }
            }
        }
        Context "Download the latest .NET Framework updates" {
            $Updates = Get-LatestNetFrameworkUpdate
            $Target = $env:TEMP
            $Downloads = Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest
            ForEach ($Update in $Updates) {
                ForEach ($url in $update.URL) {
                    $Filename = Split-Path $url -Leaf
                    It "Given updates returned from Get-LatestNetFrameworkUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                        (Join-Path $Target $Filename) | Should -Exist
                    }
                    It "Should match actual downloaded file and Get-LatestNetFrameworkUpdate output: [$($Update.Version), $($Update.Architecture)]" {
                        $Downloads.Target -contains (Join-Path $Target $Filename) | Should -Be $True
                    }
                }
            }
        }
        Context "Download the latest Windows 8.1 Monthly Rollup updates" {
            $Updates = Get-LatestMonthlyRollup
            $Target = $env:TEMP
            $Downloads = Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest
            ForEach ($Update in $Updates) {
                $Filename = Split-Path $Update.Url -Leaf
                It "Given updates returned from Get-LatestMonthlyRollup, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                    (Join-Path $Target $Filename) | Should -Exist
                }
                It "Should match actual downloaded file and Get-LatestMonthlyRollup output: [$($Update.Version), $($Update.Architecture)]" {
                    $Downloads.Target -contains (Join-Path $Target $Filename) | Should -Be $True
                }
            }
        }
        Context "Download the latest Windows 7 Monthly Rollup updates" {
            $Updates = Get-LatestMonthlyRollup -Version 'Windows 7'
            $Target = $env:TEMP
            $Downloads = Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest
            ForEach ($Update in $Updates) {
                $Filename = Split-Path $Update.Url -Leaf
                It "Given updates returned from Get-LatestMonthlyRollup, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                    (Join-Path $Target $Filename) | Should -Exist
                }
                It "Should match actual downloaded file and Get-LatestMonthlyRollup output: [$($Update.Version), $($Update.Architecture)]" {
                    $Downloads.Target -contains (Join-Path $Target $Filename) | Should -Be $True
                }
            }
        }
    }
}
