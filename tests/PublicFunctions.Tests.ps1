<#
    .SYNOPSIS
        Public Pester function tests.
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
    # Get list of updates
    Write-Host "Getting Windows updates. This might take a while." -ForegroundColor Cyan
    $CumulativeUpdates = Get-LatestCumulativeUpdate
    $CumulativeUpdates1809 = Get-LatestCumulativeUpdate -Version '1809'
    $CumulativeUpdates1803 = Get-LatestCumulativeUpdate -Version '1803'
    $CumulativeUpdates1709 = Get-LatestCumulativeUpdate -Version '1709'
    $CumulativeUpdates1703 = Get-LatestCumulativeUpdate -Version '1703'
    $CumulativeUpdates1607 = Get-LatestCumulativeUpdate -Version '1607'
    $FlashUpdates = Get-LatestAdobeFlashUpdate
    $StackUpdates = Get-LatestServicingStackUpdate
    $StackUpdates1809 = Get-LatestServicingStackUpdate -Version '1809'
    $StackUpdates1803 = Get-LatestServicingStackUpdate -Version '1803'
    $StackUpdates1709 = Get-LatestServicingStackUpdate -Version '1709'
    $NetUpdates = Get-LatestNetFrameworkUpdate
    $DefenderUpdates = Get-LatestWindowsDefenderUpdate
    $8RollupUpdates = Get-LatestMonthlyRollup -OperatingSystem 'Windows8'
    $7RollupUpdates = Get-LatestMonthlyRollup -OperatingSystem 'Windows7'
    Write-Host "Updates retrieved. Starting tests." -ForegroundColor Cyan

    Describe 'Get-LatestCumulativeUpdate' {
        Context "Returns a valid list of Cumulative updates" {
            It "Given no arguments, returns an array" {
                $CumulativeUpdates.Count | Should -BeGreaterThan 0
            }
            It "Given no arguments, returns an array of updates" {
                $CumulativeUpdates | Should -BeOfType System.Management.Automation.PSObject
            }
            ForEach ($Update in $CumulativeUpdates) {
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
            ForEach ($Update in $CumulativeUpdates) {
                It "Given '1903' returns updates for version 1903: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Cumulative.*1903" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1903" | Should -Not -BeNullOrEmpty
                }
            }
            ForEach ($Update in $CumulativeUpdates1809) {
                It "Given '1809' returns updates for version 1809: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Cumulative.*1809" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1809" | Should -Not -BeNullOrEmpty
                }
            }
            ForEach ($Update in $CumulativeUpdates1803) {
                It "Given '1803' returns updates for version 1803: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Cumulative.*1803" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1803" | Should -Not -BeNullOrEmpty
                }
            }
            ForEach ($Update in $CumulativeUpdates1709) {
                It "Given '1709' returns updates for version 1709: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Cumulative.*1709" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1709" | Should -Not -BeNullOrEmpty
                }
            }
            ForEach ($Update in $CumulativeUpdates1703) {
                It "Given '1703' returns updates for version 1703: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Cumulative.*1703" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1703" | Should -Not -BeNullOrEmpty
                }
            }
            ForEach ($Update in $CumulativeUpdates1607) {
                It "Given '1607' returns updates for version 1607: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Cumulative.*1607" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1607" | Should -Not -BeNullOrEmpty
                }
            }
        }
    }

    Describe 'Get-LatestAdobeFlashUpdate' {
        Context "Returns a valid list of Adobe Flash Player updates" {
            It "Given no arguments, returns an array" {
                $FlashUpdates.Count | Should -BeGreaterThan 0
            }
            It "Given no arguments, returns an array of updates" {
                $FlashUpdates | Should -BeOfType System.Management.Automation.PSObject
            }
            ForEach ($Update in $FlashUpdates) {
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
            ForEach ($Update in $FlashUpdates) {
                It "Given no arguments, returns updates for Adobe Flash Player: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match ".*Adobe Flash Player.*" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                }
            }
        }
    }

    Describe 'Get-LatestServicingStack' {
        Context "Returns a valid list of Servicing Stack updates" {
            It "Given no arguments, returns an array of updates" {
                $StackUpdates | Should -BeOfType System.Management.Automation.PSObject
            }
            It "Given no arguments, returns an array" {
                $StackUpdates.Count | Should -BeGreaterThan 0
            }
            ForEach ($Update in $StackUpdates) {
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
            ForEach ($Update in $StackUpdates) {
                It "Given no arguments, returns updates for Servicing Stack: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Servicing stack update.*" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1607|1703|1709|1803|1809|1903" | Should -Not -BeNullOrEmpty
                }
            }
        }
        Context "Returns expected results for each Windows 10 version" {
            ForEach ($Update in $StackUpdates1809) {
                It "Given '1809' returns updates for version 1809: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Servicing stack update.*" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1809" | Should -Not -BeNullOrEmpty
                }
            }
            ForEach ($Update in $StackUpdates1803) {
                It "Given '1803' returns updates for version 1803: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Servicing stack update.*" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1803" | Should -Not -BeNullOrEmpty
                }
            }
            ForEach ($Update in $StackUpdates1709) {
                It "Given '1709' returns updates for version 1709: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match "Servicing stack update.*" | Should -Not -BeNullOrEmpty
                    $Update.Architecture -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                    $Update.Version -match "1709" | Should -Not -BeNullOrEmpty
                }
            }
        }
    }

    Describe 'Get-LatestNetFrameworkUpdate' {
        Context "Returns a valid cumulative .NET Framework update" {
            It "Given an OS as argument, returns an array of updates" {
                $NetUpdates | Should -BeOfType System.Management.Automation.PSObject
            }
            ForEach ($Update in $NetUpdates) {
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
            ForEach ($Update in $NetUpdates) {
                It "Returns a cumulative update for .NET Framework: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match ".*Cumulative Update for .NET Framework.*" | Should -Not -BeNullOrEmpty
                }
            }
        }
    }

    Describe 'Get-LatestMonthlyRollup' {
        Context "Returns expected results with Monthly Rollup updates array" {
            ForEach ($Update in $8RollupUpdates) {
                It "Returns a Monthly Rollup update: [$($Update.Version), $($Update.Architecture)]" {
                    $Update.Note -match ".*Monthly Rollup.*" | Should -Not -BeNullOrEmpty
                }
            }
        }
        Context "Returns a valid Windows 8.1 monthly rollup update" {
            It "Given an OS as argument, returns an array of updates" {
                $8RollupUpdates | Should -BeOfType System.Management.Automation.PSObject
            }
            ForEach ($Update in $8RollupUpdates) {
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
            It "Given an OS as argument, returns an array of updates" {
                $7RollupUpdates | Should -BeOfType System.Management.Automation.PSObject
            }
            ForEach ($Update in $7RollupUpdates) {
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
        Context "Returns expected results with Windows Defender updates array" {
            ForEach ($Update in $DefenderUpdates) {
                It "Returns a Windows Defender update" {
                    $Update.Note -match ".*Monthly Rollup.*" | Should -Not -BeNullOrEmpty
                }
            }
        }
        Context "Returns a valid Windows Defender update" {
            It "Returns an array of updates" {
                $DefenderUpdates | Should -BeOfType System.Management.Automation.PSObject
            }
            ForEach ($Update in $DefenderUpdates) {
                It "Given no arguments, returns a valid array with expected properties" {
                    $Update.KB.Length | Should -BeGreaterThan 0
                    $Update.Note.Length | Should -BeGreaterThan 0
                    $Update.URL.Length | Should -BeGreaterThan 0
                }
            }
        } 
    }

    # Skip download tests unless running in AppVeyor.
    If (Test-Path -Path 'env:APPVEYOR_BUILD_FOLDER') {
    
        # Download target
        $Target = $env:TEMP

        Describe 'Save-LatestUpdate' {
            Context "Download the latest Windows 10 Cumulative updates" {
                $Downloads = Save-LatestUpdate -Updates $CumulativeUpdates -Path $Target -ForceWebRequest
                ForEach ($Update in $CumulativeUpdates) {
                    $Filename = Split-Path $Update.Url -Leaf
                    It "Given updates returned from Get-LatestCumulativeUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                        (Join-Path $Target $Filename) | Should -Exist
                    }
                }
                ForEach ($Download in $Downloads) {
                    It "Output from Save-LatestUpdate should have the expected properties" {
                        $Download.KB.Length | Should -BeGreaterThan 0
                        $Download.Note.Length | Should -BeGreaterThan 0
                        $Download.Path.Length | Should -BeGreaterThan 0
                    }
                }
            }
            Context "Download the latest Adobe Flash Player updates" {
                $Downloads = Save-LatestUpdate -Updates $FlashUpdates -Path $Target -ForceWebRequest
                ForEach ($Update in $FlashUpdates) {
                    $Filename = Split-Path $Update.Url -Leaf
                    It "Given updates returned from Get-LatestAdobeFlashUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                        (Join-Path $Target $Filename) | Should -Exist
                    }
                }
                ForEach ($Download in $Downloads) {
                    It "Output from Save-LatestUpdate should have the expected properties" {
                        $Download.KB.Length | Should -BeGreaterThan 0
                        $Download.Note.Length | Should -BeGreaterThan 0
                        $Download.Path.Length | Should -BeGreaterThan 0
                    }
                }
            }
            Context "Download the latest Servicing Stack updates" {
                $Downloads = Save-LatestUpdate -Updates $StackUpdates -Path $Target -ForceWebRequest
                ForEach ($Update in $StackUpdates) {
                    $Filename = Split-Path $Update.Url -Leaf
                    It "Given updates returned from Get-LatestServicingStackUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                        (Join-Path $Target $Filename) | Should -Exist
                    }
                }
                ForEach ($Download in $Downloads) {
                    It "Output from Save-LatestUpdate should have the expected properties" {
                        $Download.KB.Length | Should -BeGreaterThan 0
                        $Download.Note.Length | Should -BeGreaterThan 0
                        $Download.Path.Length | Should -BeGreaterThan 0
                    }
                }
            }
            Context "Download the latest .NET Framework updates" {
                $Downloads = Save-LatestUpdate -Updates $NetUpdates -Path $Target -ForceWebRequest
                ForEach ($Update in $NetUpdates) {
                    ForEach ($url in $update.URL) {
                        $Filename = Split-Path $url -Leaf
                        It "Given updates returned from Get-LatestNetFrameworkUpdate, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                            (Join-Path $Target $Filename) | Should -Exist
                        }
                    }
                    ForEach ($Download in $Downloads) {
                        It "Output from Save-LatestUpdate should have the expected properties" {
                            $Download.KB.Length | Should -BeGreaterThan 0
                            $Download.Note.Length | Should -BeGreaterThan 0
                            $Download.Path.Length | Should -BeGreaterThan 0
                        }
                    }
                }
            }
            Context "Download the latest Windows 8.1 Monthly Rollup updates" {
                $Downloads = Save-LatestUpdate -Updates $8RollupUpdates -Path $Target -ForceWebRequest
                ForEach ($Update in $8RollupUpdates) {
                    $Filename = Split-Path $Update.Url -Leaf
                    It "Given updates returned from Get-LatestMonthlyRollup, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                        (Join-Path $Target $Filename) | Should -Exist
                    }
                }
                ForEach ($Download in $Downloads) {
                    It "Output from Save-LatestUpdate should have the expected properties" {
                        $Download.KB.Length | Should -BeGreaterThan 0
                        $Download.Note.Length | Should -BeGreaterThan 0
                        $Download.Path.Length | Should -BeGreaterThan 0
                    }
                }
            }
            Context "Download the latest Windows 7 Monthly Rollup updates" {
                $Downloads = Save-LatestUpdate -Updates $7RollupUpdates -Path $Target -ForceWebRequest
                ForEach ($Update in $7RollupUpdates) {
                    $Filename = Split-Path $Update.Url -Leaf
                    It "Given updates returned from Get-LatestMonthlyRollup, it successfully downloads the update: [$($Update.Version), $($Update.Architecture)]" {
                        (Join-Path $Target $Filename) | Should -Exist
                    }
                }
                ForEach ($Download in $Downloads) {
                    It "Output from Save-LatestUpdate should have the expected properties" {
                        $Download.KB.Length | Should -BeGreaterThan 0
                        $Download.Note.Length | Should -BeGreaterThan 0
                        $Download.Path.Length | Should -BeGreaterThan 0
                    }
                }
            }
            Context "Download the latest Windows Defender updates" {
                $Downloads = Save-LatestUpdate -Updates $DefenderUpdates -Path $Target -ForceWebRequest
                ForEach ($Update in $DefenderUpdates) {
                    ForEach ($url in $update.URL) {
                        $Filename = Split-Path $url -Leaf
                        It "Given updates returned from Get-LatestWindowsDefenderUpdate, it successfully downloads the update" {
                            (Join-Path $Target $Filename) | Should -Exist
                        }
                    }
                }
                ForEach ($Download in $Downloads) {
                    It "Output from Save-LatestUpdate should have the expected properties" {
                        $Download.KB.Length | Should -BeGreaterThan 0
                        $Download.Note.Length | Should -BeGreaterThan 0
                        $Download.Path.Length | Should -BeGreaterThan 0
                    }
                }
            }
            <#Context "Download via BITS Transfer" {
                Disable-NetFirewallRule -DisplayName 'Core Networking - Group Policy (TCP-Out)'
                $DownloadPath = Join-Path -Path $Target -ChildPath ([System.IO.Path]::GetRandomFileName())
                New-Item -Path $DownloadPath -ItemType Directory -Force
                Save-LatestUpdate -Updates $StackUpdates -Path $DownloadPath
                ForEach ($Update in $StackUpdates) {
                    $Filename = Split-Path $Update.Url -Leaf
                    It "Given downloads via BITS, it successfully downloads the update" {
                        (Join-Path $DownloadPath $Filename) | Should -Exist
                    }
                }
                ForEach ($Download in $Downloads) {
                    It "Output from Save-LatestUpdate should have the expected properties" {
                        $Download.KB.Length | Should -BeGreaterThan 0
                        $Download.Note.Length | Should -BeGreaterThan 0
                        $Download.Path.Length | Should -BeGreaterThan 0
                    }
                }
            }#>
        }
    }
}
