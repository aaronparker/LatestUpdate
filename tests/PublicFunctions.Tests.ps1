# Pester tests
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $ProjectRoot = "$(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)\..\"
}
Import-Module $ProjectRoot\LatestUpdate

Describe 'Get-LatestUpdate' {
    Context "Returns a valid list of updates" {
        It "Given no arguments, returns an array" {
            $Updates = Get-LatestUpdate
            $Updates | Should -BeOfType System.Management.Automation.PSCustomObject
        }
        It "Given no arguments, returns a valid array" {
            $Updates = Get-LatestUpdate
            ForEach ( $Update in $Updates ) {
                $Update.KB.Length | Should -BeGreaterThan 0
                $Update.Note.Length | Should -BeGreaterThan 0
                $Update.URL.Length | Should -BeGreaterThan 0
            }
        }
    }
}