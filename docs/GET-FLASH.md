# Get the Latest Adobe Flash Player Update

`Get-LatestFlash` retrieves the latest Adobe Flash Player updates for Windows 10, Windows 8.1 and Windows Server from the Microsoft Update Catalog. Run `Get-LatestFlash` to return Adobe Flash Player updates for all supported platforms.

```powershell
PS C:\> Get-LatestFlash
```

## Output

`Get-LatestFlash | Format-Table` returns the Adobe Flash Player updates for all supported platforms. This will look similar to output shown below.

```powershell

KB        Arch  Version   Note                                                                                                             URL
--        ----  -------   ----                                                                                                             ---
KB4480979 x64   1809     2019-01 Security Update for Adobe Flash Player for Windows Server 2019 for x64-based Systems (KB4480979)         http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_e29e228e115d23a003d88ac9fe23a35c582a24f9.msu
KB4480979 x64   1607     2019-01 Security Update for Adobe Flash Player for Windows Server 2016 for x64-based Systems (KB4480979)         http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_5380c7317700118ad056b0dc0cdbe7e411ebd137.msu
KB4480979 x86   8Embedded 2019-01 Security Update for Adobe Flash Player for Windows Embedded 8 Standard for x86-based Systems (KB4480979) http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows8-rt-kb4480979-x86_528098441ea15096c8741650900b8d65b61c54b5.msu
KB4480979 x64   8Embedded 2019-01 Security Update for Adobe Flash Player for Windows Embedded 8 Standard for x64-based Systems (KB4480979) http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows8-rt-kb4480979-x64_c81dd361a1a876e7e958fab5406656e36640b8e7.msu
KB4480979 x86   8.1       2019-01 Security Update for Adobe Flash Player for Windows 8.1 for x86-based Systems (KB4480979)                 http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows8.1-kb4480979-x86_f4e7a2f2038c9703898f50ee4e49ea3c18679b84.msu
KB4480979 x64   8.1       2019-01 Security Update for Adobe Flash Player for Windows 8.1 for x64-based Systems (KB4480979)                 http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows8.1-kb4480979-x64_f4abb904b55db12ea6ebe76a7a3d3f491435008c.msu
KB4480979 x64   2012R2    2019-01 Security Update for Adobe Flash Player for Windows Server 2012 R2 for x64-based Systems (KB4480979)      http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows8.1-kb4480979-x64_f4abb904b55db12ea6ebe76a7a3d3f491435008c.msu
KB4480979 x64   2012      2019-01 Security Update for Adobe Flash Player for Windows Server 2012 for x64-based Systems (KB4480979)         http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows8-rt-kb4480979-x64_c81dd361a1a876e7e958fab5406656e36640b8e7.msu
KB4480979 ARM64 1809      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1809 for ARM64-based Systems (KB4480979)   http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-arm64_8b6fe9edf9a6bcdc755a202e5d1a9694141eade6.msu
KB4480979 x86   1809      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1809 for x86-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x86_71db36c61cfb9b126275b922951480f60d3f1d03.msu
KB4480979 x64   1809      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1809 for x64-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_e29e228e115d23a003d88ac9fe23a35c582a24f9.msu
KB4480979 x86   1803      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1803 for x86-based Systems (KB4480979)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x86_79d4749925422b6f12dcf2f3f221234beeaf65ae.msu
KB4480979 ARM64 1803      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1803 for ARM64-based Systems (KB4480979)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-arm64_2bac2704b0eba82ff0552eb0de647cd4e0f6b6de.msu
KB4480979 x64   1803      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1803 for x64-based Systems (KB4480979)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_929afb55a9e05a70d2323b7231f295c9da397968.msu
KB4480979 ARM64 1709      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1709 for ARM64-based Systems (KB4480979)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-arm64_932c13ee84f5a11dacf65a3539fe517152c6098b.msu
KB4480979 x86   1709      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1709 for x86-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x86_2b9ceca81accad3f11782d625d23a2e6e68fc502.msu
KB4480979 x64   1709      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1709 for x64-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_0cf606595e0479b13355f80985b8311e7a3de35e.msu
KB4480979 x86   1703      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1703 for x86-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x86_1361a9e89e43baa84e038f61ad54da73ecb08d06.msu
KB4480979 x64   1703      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1703 for x64-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_7144bfb32f3f4199d233d9b81bd653fbe76142c7.msu
KB4480979 x64   1607      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1607 for x64-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_5380c7317700118ad056b0dc0cdbe7e411ebd137.msu
KB4480979 x86   1607      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1607 for x86-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x86_cd9f0b27816d9c53ed51f9b9797e24b91c7a5716.msu
KB4480979 x64   1507      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1507 for x64-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_09bcc3fbad361d1429127043ad1986ee733557d0.msu
KB4480979 x86   1507      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1507 for x86-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x86_c52a5e89de0ce166c9717c00fffb8f5e37dd480d.msu 
```

## Filter Output

Output from `Get-LatestFlash` can be filtered to find updates for a specific processor architecture and Windows version. For example, to filter for only the 32-bit version of Windows 10 1809, use the following syntax:

```powershell
Get-LatestFlash | Where-Object { ($_.Arch -eq "x86") -and ($_.Note -match ".*Windows 10.*1809") }
```

This will return output similar to the following:

```powershell
KB        Arch  Version   Note                                                                                                             URL
--        ----  -------   ----                                                                                                             ---
KB4480979 x64   1809      2019-01 Security Update for Adobe Flash Player for Windows 10 Version 1809 for x64-based Systems (KB4480979)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480979-x64_e29e228e115d23a003d88ac9fe23a35c582a24f9.msu
```
