# Get the Latest Adobe Flash Player Update

`Get-LatestFlash` retrieves the latest Adobe Flash Player updates for Windows 10, Windows 8.1 and Windows Server from the Microsoft Update Catalog. Run `Get-LatestFlash` to return Adobe Flash Player updates for all supported platforms.

```powershell
PS C:\> Get-LatestFlash
```

## Output

`Get-LatestFlash` returns the Adobe Flash Player updates for all supported platforms. THis will look similar to output shown below.

```powershell
KB        Arch  Note                                                                                                             URL                                                                                                                                                 
--        ----  ----                                                                                                             ---                                                                                                                                                 
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows Server 2016 for x64-based Systems (KB4471331)         http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_956b7aac81ca455bcc8b0a285edd7e20e5bce8d1.msu  
KB4471331 x86   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1703 for x86-based Systems (KB4471331)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x86_31ab604e3ec4077e01242b0ba24cfd19741a0ad4.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1703 for x64-based Systems (KB4471331)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_15abfabcba5fa45d94b36e06afd1d8eb9ee67f52.msu  
KB4471331 x86   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1607 for x86-based Systems (KB4471331)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x86_59ea46a76e5c932fb7f766661599b278e516218f.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1607 for x64-based Systems (KB4471331)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_956b7aac81ca455bcc8b0a285edd7e20e5bce8d1.msu  
KB4471331 x86   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1507 for x86-based Systems (KB4471331)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x86_69f53c132aed2dfd3517ff9b8af5ad91048800a5.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1507 for x64-based Systems (KB4471331)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_f202191f922afe1ee58a77ae5419d8ec9faa18f7.msu  
KB4471331 x86   2018-12 Security Update for Adobe Flash Player for Windows Embedded 8 Standard for x86-based Systems (KB4471331) http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows8-rt-kb4471331-x86_d2498fdabaca46ba8064e524bab264401273f3aa.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows Embedded 8 Standard for x64-based Systems (KB4471331) http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows8-rt-kb4471331-x64_0e3192ce3036b2cd826c6d9b43b12da5f2db9d62.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows Server 2012 for x64-based Systems (KB4471331)         http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows8-rt-kb4471331-x64_0e3192ce3036b2cd826c6d9b43b12da5f2db9d62.msu  
KB4471331 x86   2018-12 Security Update for Adobe Flash Player for Windows 8.1 for x86-based Systems (KB4471331)                 http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows8.1-kb4471331-x86_f83b59b9f3d5fbfcceab60ce82d3addb0d6af874.msu   
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows Server 2012 R2 for x64-based Systems (KB4471331)      http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows8.1-kb4471331-x64_9cde17312f6c348894fda55da76741d5a4ee4805.msu   
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows 8.1 for x64-based Systems (KB4471331)                 http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows8.1-kb4471331-x64_9cde17312f6c348894fda55da76741d5a4ee4805.msu   
KB4471331 ARM64 2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1709 for ARM64-based Systems (KB4471331)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-arm64_c9e25c39321e03d498b01414abb3bff25392c2fa.msu
KB4471331 ARM64 2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1803 for ARM64-based Systems (KB4471331)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-arm64_3d734c4ecf36b26085dbb7f2b7d0939d6c550de5.msu
KB4471331 x86   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1709 for x86-based Systems (KB4471331)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x86_19d7468af8f140cd2897ed4048a280c58f082bd6.msu  
KB4471331 x86   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1803 for x86-based Systems (KB4471331)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x86_ee8e1eb1358d834e1f5eb4e012cd2a9865d58bea.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1709 for x64-based Systems (KB4471331)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_fbbdcd7f2ce2e560abdafb959d0f9a1cd4d60580.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1803 for x64-based Systems (KB4471331)     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_5fd93a2ae1e782a3a3b5f26297994c039f090d19.msu  
KB4471331 ARM64 2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1809 for ARM64-based Systems (KB4471331)   http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-arm64_5643d2dd645e748e8739859058134db52f3043e3.msu
KB4471331 x86   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1809 for x86-based Systems (KB4471331)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x86_da283dc908e120ac189768f56cf599deca9f3c1e.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows Server 2019 for x64-based Systems (KB4471331)         http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_f40a66c873644c2b88ed389882364a8d1fc52328.msu  
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1809 for x64-based Systems (KB4471331)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_f40a66c873644c2b88ed389882364a8d1fc52328.msu  
```

## Filter Output

Output from `Get-LatestFlash` can be filtered to find updates for a specific processor architecture and Windows version. For example, to filter for only the 32-bit version of Windows 10 1809, use the following syntax:

```powershell
Get-LatestFlash | Where-Object { ($_.Arch -eq "x86") -and ($_.Note -match ".*Windows 10.*1809") }
```

This will return output similar to the following:

```powershell
KB        Arch  Note                                                                                                             URL                                                                                                                                                 
--        ----  ----                                                                                                             ---                                                                                                                        
KB4471331 x64   2018-12 Security Update for Adobe Flash Player for Windows 10 Version 1809 for x64-based Systems (KB4471331)     http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4471331-x64_f40a66c873644c2b88ed389882364a8d1fc52328.msu  
```
