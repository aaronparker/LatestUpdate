# Pester tests
. ..\LatestUpdate\Private\Get-ValidPath.ps1
Describe 'Get-LatestUpdate' {
    Context "Returns a valid list of updates" {
        It "Given no arguments, returns the latest update for Windows 10" {
            $Updates = Get-LatestUpdate
            $Updates | Should -Not -Be $Null
        }
    }
}