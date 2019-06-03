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

Describe 'Get-LatestUpdate' {
    Context "Returns a valid list of Cumulative updates" {
        $Updates = Get-LatestUpdate
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
        }
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Arch.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Windows 10: Returns expected results with -Build" {
        It "Given '18362' returns updates for build 1903" {
            $Updates = Get-LatestUpdate
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1903" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1903" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '17763' returns updates for build 1809" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '17763'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1809" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1809" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '17134' returns updates for build 1803" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '17134'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1803" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1803" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '16299' returns updates for build 1709" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '16299'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1709" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1709" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '15063' returns updates for build 1703" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '15063'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1703" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1703" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '14393' returns updates for build 1607" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '14393'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1607" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1607" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '10240' returns updates for build 1507" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '10240'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1507" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1507" | Should -Not -BeNullOrEmpty
            }
        }
    }
    Context "Returns expected results for Windows 8.1" {
        $Updates = Get-LatestUpdate -WindowsVersion Windows8
        It "Given '-WindowsVersion Windows8' returns updates for Windows 8.1" {
            ForEach ($Update in $Updates) {
                $Update.Note -match "Security Monthly Quality Rollup*" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "8.1|2012R2" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
        }
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Arch.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results for Windows 7" {
        $Updates = Get-LatestUpdate -WindowsVersion Windows7
        It "Given '-WindowsVersion Windows7' returns updates for Windows 7" {
            ForEach ($Update in $Updates) {
                $Update.Note -match "Security Monthly Quality Rollup*" | Should -Not -BeNullOrEmpty
                $Update.Arch -match "x86|x64|Itanium" | Should -Not -BeNullOrEmpty
                $Update.Version -match "7|2008R2|7Embedded" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
        }
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Arch.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
}

Describe 'Get-LatestFlash' {
    $Updates = Get-LatestFlash
    Context "Returns a valid list of Adobe Flash Player updates" {
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
        }
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Arch.Length | Should -BeGreaterThan 0
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
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Get-LatestServicingStack' {
    $Updates = Get-LatestServicingStack
    Context "Returns a valid list of Servicing Stack updates" {
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
        }
        It "Given no arguments, returns an array" {
            $Updates.Count | Should -BeGreaterThan 0
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Arch.Length | Should -BeGreaterThan 0
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
                $Update.Arch -match "x86|x64|ARM64" | Should -Not -BeNullOrEmpty
                $Update.Version -match "1607|1703|1709|1803|1809|1903" | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Get-LatestNetFramework' {
    $Updates = Get-LatestNetFramework -OS "Windows Server 2019"
    Context "Returns a valid cumulative .NET Framework update" {
        It "Given an OS as argument, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Arch.Length | Should -BeGreaterThan 0
                $Update.Version.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Returns expected results with Flash updates array" {
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
            $Updates = Get-LatestUpdate
            $Target = $env:TEMP
            Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest -Verbose
            It "Given updates returned from Get-LatestUpdate, it successfully downloads the update" {
                ForEach ($Update in $Updates) {
                    $Filename = Split-Path $Update.Url -Leaf
                    Write-Host "Check for $(Join-Path $Target $Filename)."
                    (Join-Path $Target $Filename) | Should -Exist
                }
            }
        }
        Context "Download the latest Adobe Flash Player updates" {
            $Updates = Get-LatestFlash
            $Target = $env:TEMP
            Save-LatestUpdate -Updates $Updates -Path $Target -ForceWebRequest -Verbose
            It "Given updates returned from Get-LatestFlash, it successfully downloads the update" {
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
