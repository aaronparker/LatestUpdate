# Pester tests
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $ProjectRoot = "$(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)\..\"
}
Import-Module (Join-Path $ProjectRoot "LatestUpdate")

Describe 'Get-LatestUpdate' {
    Context "Returns a valid list of updates" {
        $Updates = Get-LatestUpdate
        It "Given no arguments, returns an array of updates" {
            $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
        }
        It "Given no arguments, returns a valid array with expected properties" {
            ForEach ($Update in $Updates) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Arch.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context "Windows 10: Returns expected results with -Build" {
        It "Given '17763' returns updates for build 1809" {
            $Updates = Get-LatestUpdate
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1809" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '17134' returns updates for build 1803" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '17134'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1803" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '16299' returns updates for build 1709" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '16299'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1709" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '15063' returns updates for build 1703" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '15063'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1703" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '14393' returns updates for build 1607" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '14393'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1607" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '10586' returns updates for build 1511" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '10586'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1511" | Should -Not -BeNullOrEmpty
            }
        }
        It "Given '10240' returns updates for build 1507" {
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build '10240'
            ForEach ($Update in $Updates) {
                $Update.Note -match "Cumulative.*1507" | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Save-LatestUpdate' {
    Context "Download the latest Windows 10 update" {
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
}
