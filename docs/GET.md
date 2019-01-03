# Get the Latest Update

`Get-LatestUpdate` retrieves the latest update from the Windows 10 Update History page at [https://support.microsoft.com/en-au/help/4464619](https://support.microsoft.com/en-au/help/4464619). Run `Get-LatestUpdate` with no additional switches to return the latest update for the most recent Windows 10 build for all processor architectures.

```powershell
PS C:\> Get-LatestUpdate
```

This returns the most recent update for Windows 10 x86, x64 and ARM64 as well as Windows Server. Additional examples of Get-LatestUpdate syntax include:

Return the cumulative update for Windows 10 1607 and Windows Server 2016:

```powershell
PS C:\> Get-LatestUpdate -WindowsVersion Windows10 -Build 14393
```

Return the cumulative update for latest release (Semi-Annual Channel) of Windows 10 and Windows Server:

```powershell
PS C:\> Get-LatestUpdate -WindowsVersion Windows10
```

Return the cumulative update for latest release of Windows 10 and Windows Server 1709:

```powershell
PS C:\> Get-LatestUpdate -WindowsVersion Windows10 -Build 16299
```

## Output

`Get-LatestUpdate` returns an array of available updates with KB article (KB), processor architecture (Arch), update description (Note) and the URL to the update itself (URL). An example output for Windows 10 is shown below.

```powershell
KB        Arch  Note                                                                                      URL                                                                                                                                               
--        ----  ----                                                                                      ---                                                                                                                                               
KB4483235 ARM64 2018-12 Cumulative Update for Windows 10 Version 1809 for ARM64-based Systems (KB4483235) http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4483235-arm64_f2375c94f1bd67092a35c0f867b50f8a4f44f914.msu
KB4483235 x86   2018-12 Cumulative Update for Windows 10 Version 1809 for x86-based Systems (KB4483235)   http://download.windowsupdate.com/c/msdownload/update/software/secu/2018/12/windows10.0-kb4483235-x86_651ecd2feec0f84ef346e918a7c50049f0384810.msu
KB4483235 x64   2018-12 Cumulative Update for Windows Server 2019 for x64-based Systems (KB4483235)       http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4483235-x64_9d25f46d4a9da7dd295f8a6412a64eca9de4ed82.msu
KB4483235 x64   2018-12 Cumulative Update for Windows 10 Version 1809 for x64-based Systems (KB4483235)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/12/windows10.0-kb4483235-x64_9d25f46d4a9da7dd295f8a6412a64eca9de4ed82.msu
```

## Operating System Support

Updates for the following operating systems can be returned:

* Windows 10 and Windows Server (including the available builds). Returns the latest Cumulative update for these versions of Windows.
* Windows 8.1 and Windows Server 2012 R2. Returns the latest Monthly Rollup for these version of Windows.
* Windows 7 and Windows Server 2008 R2. Returns the latest Monthly Rollup for these version of Windows.

### Filtering for Windows versions

Returning updates for specific versions, builds and processor architectures differs between Windows 10 and Windows 8.1/7. By default, updates for Windows 10 are returned.

* `-WindowsVersion`: use to specific the version of Windows to search for updates. Windows10, Windows8 and Windows7
* `-Build`: only applicable with '-WindowsVersion Windows10'. Specify a build number - '17763', '17134', '16299', '15063', '14393', '10586', '10240'.
