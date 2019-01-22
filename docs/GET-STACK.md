# Get the Latest Servicing Stack Update

`Get-LatestServicingStack` retrieves the latest Servicing Stack updates for Windows 10, Windows Server 2016 and Windows Server 2019 from the Microsoft Update Catalog. Run `Get-LatestServicingStack` to return Servicing Stack updates for all supported platforms.

```powershell
PS C:\> Get-LatestServicingStack
```

## Output

`Get-LatestServicingStack | Format-Table` returns the Windows 10 Servicing Stack updates. This will look similar to output shown below.

```powershell
KB        Arch  Version Note                                                                                         URL
--        ----  ------- ----                                                                                         ---
KB4470788 x64   1809    2018-11 Update for Windows Server 2019 for x64-based Systems (KB4470788)                     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/11/windows10.0-kb4470788-x64_76f112f2b02b1716cdc0cab6c40f73764759cb0d.msu
KB4470788 x86   1809    2018-11 Update for Windows 10 Version 1809 for x86-based Systems (KB4470788)                 http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/11/windows10.0-kb4470788-x86_4073458a480724d1f027856e79c09b82553c6c7f.msu
KB4470788 x64   1809    2018-11 Update for Windows 10 Version 1809 for x64-based Systems (KB4470788)                 http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/11/windows10.0-kb4470788-x64_76f112f2b02b1716cdc0cab6c40f73764759cb0d.msu
KB4470788 ARM64 1809    2018-11 Update for Windows 10 Version 1809 for ARM64-based Systems (KB4470788)               http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/11/windows10.0-kb4470788-arm64_22d838e23046247c3a3b67b1a05d2b262e52de10.msu
KB4477137 x64   1803    2018-12 Update for Windows 10 Version 1803 for x64-based Systems (KB4477137)                 http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4477137-x64_0ff345c6c9369636f7814230fbeaf0d844a03858.msu
KB4477137 x64   1803    2018-12 Update for Windows Server 2016 (1803) for x64-based Systems (KB4477137)              http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4477137-x64_0ff345c6c9369636f7814230fbeaf0d844a03858.msu
KB4477137 x86   1803    2018-12 Update for Windows 10 Version 1803 for x86-based Systems (KB4477137)                 http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4477137-x86_f00b7135a3ec4e9686020970f99528e74441928b.msu
KB4477137 ARM64 1803    2018-12 Update for Windows 10 Version 1803 for ARM64-based Systems (KB4477137)               http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4477137-arm64_ee1bdd834430d848fc94abfbd38ad6273c80b6d3.msu
KB4477136 x64   1709    2018-12 Update for Windows 10 Version 1709 for x64-based Systems (KB4477136)                 http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4477136-x64_5bfa3bb10370a5cee17c6239c99d97cb54464f95.msu
KB4477136 x86   1709    2018-12 Update for Windows 10 Version 1709 for x86-based Systems (KB4477136)                 http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4477136-x86_94279b1a48e88846a80bd00b14b443c8f0cf7084.msu
KB4477136 x64   1709    2018-12 Update for Windows Server 2016 (1709) for x64-based Systems (KB4477136)              http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4477136-x64_5bfa3bb10370a5cee17c6239c99d97cb54464f95.msu
KB4477136 ARM64 1709    2018-12 Update for Windows 10 Version 1709 for ARM64-based Systems (KB4477136)               http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4477136-arm64_6c90bdc41e5d9af71accea2966be886d5147c193.msu
KB4486458 x64   1703    2019-01 Servicing Stack Update for Windows 10 Version 1703 for x64-based Systems (KB4486458) http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4486458-x64_e7ade567fd54a1d63f3ac608f1fab0c0c90bca3b.msu
KB4486458 x86   1703    2019-01 Servicing Stack Update for Windows 10 Version 1703 for x86-based Systems (KB4486458) http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4486458-x86_7bffb9e01d667bcc6d0aa23800b36b235d0b1ad9.msu
KB4465659 x64   1607    2018-11 Update for Windows 10 Version 1607 for x64-based Systems (KB4465659)                 http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/11/windows10.0-kb4465659-x64_af8e00c5ba5117880cbc346278c7742a6efa6db1.msu
KB4465659 x86   1607    2018-11 Update for Windows 10 Version 1607 for x86-based Systems (KB4465659)                 http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/11/windows10.0-kb4465659-x86_7a2b6eccab414862c96702cf6092c67ed540e7f3.msu
KB4465659 x64   1607    2018-11 Update for Windows Server 2016 for x64-based Systems (KB4465659)                     http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/11/windows10.0-kb4465659-x64_af8e00c5ba5117880cbc346278c7742a6efa6db1.msu
```

## Filter Output

Output from `Get-LatestServicingStack` can be filtered to find updates for a specific processor architecture and Windows version. For example, to filter for only the 32-bit version of Windows 10 1809, use the following syntax:

```powershell
Get-LatestServicingStack | Where-Object { ($_.Arch -eq "x86") -and ($_.Version -match "1809") }
```

This will return output similar to the following:

```powershell
KB        Arch  Version Note                                                                                         URL
--        ----  ------- ----                                                                                         ---                                                   
KB4470788 x86   1809    2018-11 Update for Windows 10 Version 1809 for x86-based Systems (KB4470788)                 http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/11/windows10.0-kb4470788-x86_4073458a480724d1f027856e79c09b82553c6c7f.msu
```
