# Pester tests
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $ProjectRoot = "$(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)\..\"
}
. $projectRoot\LatestUpdate\Private\Get-ValidPath.ps1
$RelPath = "..\LatestUpdate\"
Describe 'Get-ValidPath' {
    Context "Return valid path" {
        It "Given a relative path, it returns a fully qualified path" {
            $Path = Get-ValidPath -Path $RelPath
            $((Resolve-Path $RelPath).Path).TrimEnd("\") | Should -Be $Path
        }
    }
    Context "Fix trailing backslash" {
        It "Given a path, it returns a without a trailing backslack" {
            $Path = Get-ValidPath -Path $RelPath
            $Path.Substring($Path.Length - 1) -eq "\" | Should -Not -Be $True
        }
    }
}