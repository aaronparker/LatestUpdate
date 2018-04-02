# Pester tests
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $ProjectRoot = "$(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)\..\"
}
Import-Module $ProjectRoot\LatestUpdate -Force

InModuleScope LatestUpdate {
    Describe 'Import-MdtModule' {
        Context "Importing the MDT PowerShell module" {
            Function Get-ValidPath {}
            Mock -CommandName Get-ValidPath -MockWith { $ProjectRoot }
            Mock Import-Module { $True }
            It "Imports the MDT PowerShell module and returns True" {
                Import-MdtModule | Should Be @($True, $True)
            }
        }
    }

    Describe 'New-MdtDrive' {
        $Path = "\\server\share"
        $Drive = "DS004"
        Function Get-MdtPersistentDrive {}
        Function New-PSDrive {}
        Function Add-MDTPersistentDrive {}
        Context "Creates a new MDT drive" {
            Mock -CommandName Get-MdtPersistentDrive -MockWith {
                $obj = [PSCustomObject]@{
                    Name = $Drive
                    Path = $Path
                    Description = "MDT drive created by New-MdtDrive"
                }
                Write-Output $obj
            }
            Mock -CommandName New-PSDrive -MockWith {
                $obj = [PSCustomObject]@{
                    Name = $Drive
                    Provider = "MDTProvider"
                    Root = $Path
                }
                Write-Output $obj
            }
            Mock -CommandName Add-MdtPersistentDrive -MockWith {
                $obj = [PSCustomObject]@{
                    Name = $Drive
                    Provider = "MDTProvider"
                    Root = $Path
                }
                Write-Output $obj
            }
            It "Successfully creates the MDT drive" {
                New-MdtDrive -Drive $Drive -Path $Path | Should -Be $Drive
            }
        }
    }

    Describe 'New-MdtPackagesFolder' {
        Context "Packages folder exists" {
            Mock Test-Path { $True }
            It "Returns True if the Packages folder exists" {
                New-MdtPackagesFolder -Drive "DS001" -Path "Windows 10" | Should Be $True
            }
        }
        Context "Creates a new Packages folder" {
            Function New-Item {}
            Mock Test-Path { $False }
            Mock New-Item { $obj = [PSCustomObject]@{Name = "Windows 10"} }
            It "Successfully creates a Packages folder" {
                New-MdtPackagesFolder -Drive "DS001" -Path "Windows 10" | Should Be $True
            }
        }
    }

    Describe 'Get-ValidPath' {
        $RelPath = "..\LatestUpdate\"
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

    Describe 'Select-LatestUpdate' {
        $Upd1 = [PSCustomObject]@{
            id = 148
            text = "KB4089848 (OS Build 16299.334)"
            level = 2
            articleId = "4089848"
            articleType = "article"
        }
        $Upd2 = [PSCustomObject]@{
            id = 144
            text = "KB4088776 (OS Build 16299.309)"
            level = 2
            articleId = "4088776"
            articleType = "article"
        }
        $KbId = @($Upd1, $Upd2)
        Context "Selects the latest update" {
            It "Given a list of updates, selects the latest one" {
                ($KbId | Select-LatestUpdate).id | Should -Be 148
            }
        }
    }

    Describe 'Select-UniqueUrl' {
        $Upd1 = [PSCustomObject]@{
            KB = "KB4089848"
            Note = "2018-03 Cumulative Update for Windows Server 2016 (1709) for x64-based Systems (KB4089848)"
            URL = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2018/03/windows10.0-kb4089848-x64_db7c5aad31c520c6983a937c3d53170e84372b11.msu"
        }
        $Upd2 = [PSCustomObject]@{
            KB = "KB4089848"
            Note = "2018-03 Cumulative Update for Windows 10 Version 1709 for x64-based Systems (KB4089848)"
            URL = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2018/03/windows10.0-kb4089848-x64_db7c5aad31c520c6983a937c3d53170e84372b11.msu"
        }
        $Updates = @($Upd1, $Upd2)
        Context "Select a single update" {
            It "Given a list of updates returns a single URL" {
                (Select-UniqueUrl -Updates $Updates).Count | Should -Be 1
            }
        }
    }

    Describe 'Test-PSCore' {
        $Version = '6.0.0'
        Context "Tests whether we are running on PowerShell Core" {
            It "Imports the MDT PowerShell module and returns True" {
                If (($PSVersionTable.PSVersion -ge [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Core")) {
                    Test-PSCore | Should Be $True
                }
            }
        }
        Context "Tests whether we are running on Windows PowerShell" {
            It "Returns False if running Windows PowerShell" {
                If (($PSVersionTable.PSVersion -lt [version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Desktop")) {
                    Test-PSCore | Should Be $False
                }
            }
        }
    }
}