# Pester tests
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