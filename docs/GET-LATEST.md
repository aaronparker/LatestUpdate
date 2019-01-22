# Get the Latest Windows Cumulative or Monthly Rollup Updates

`Get-LatestUpdate` retrieves the latest Cumulative update from the Windows 10 Update History page at [https://support.microsoft.com/en-au/help/4464619](https://support.microsoft.com/en-au/help/4464619). Run `Get-LatestUpdate` with no additional switches to return the latest update for the most recent Windows 10 build for all processor architectures.

```powershell
PS C:\> Get-LatestUpdate
```

This returns the most recent update for Windows 10 x86, x64 and ARM64 as well as Windows Server.

## Operating System Support

Updates for the following operating systems can be returned:

* Windows 10 and Windows Server (including the available builds). Returns the latest Cumulative update for these versions of Windows.
* Windows 8.1 and Windows Server 2012 R2. Returns the latest Monthly Rollup for these version of Windows.
* Windows 7 and Windows Server 2008 R2. Returns the latest Monthly Rollup for these version of Windows.

### Filtering for Windows versions

Returning updates for specific versions, builds and processor architectures differs between Windows 10 and Windows 8.1/7. By default, updates for Windows 10 are returned.

* `-WindowsVersion`: use to specific the version of Windows to search for updates. Windows10, Windows8 and Windows7
* `-Build`: only applicable with '-WindowsVersion Windows10'. Specify a build number - '17763', '17134', '16299', '15063', '14393', '10586', '10240'.

## Examples

Additional examples of Get-LatestUpdate syntax include:

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

`Get-LatestUpdate | Format-Table` returns an array of available updates with KB article (KB), processor architecture (Arch), update description (Note) and the URL to the update itself (URL). An example output for Windows 10 is shown below.

```powershell
KB        Arch  Version  Note                                                                                      URL
--        ----  -------  ----                                                                                      ---
KB4480116 x64   1809     2019-01 Cumulative Update for Windows Server 2019 for x64-based Systems (KB4480116)       http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480116-x64_4c8672ed7ce1d839421a36c681f9d3f64c31fe37.msu
KB4480116 ARM64 1809     2019-01 Cumulative Update for Windows 10 Version 1809 for ARM64-based Systems (KB4480116) http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/01/windows10.0-kb4480116-arm64_bacbad707cce6698fde3ffbb1daca2f555009e08.msu
KB4480116 x86   1809     2019-01 Cumulative Update for Windows 10 Version 1809 for x86-based Systems (KB4480116)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480116-x86_001457768574e3a4f0289c6a958d6680ee1fc90b.msu
KB4480116 x64   1809     2019-01 Cumulative Update for Windows 10 Version 1809 for x64-based Systems (KB4480116)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480116-x64_4c8672ed7ce1d839421a36c681f9d3f64c31fe37.msu
```

## Filter Output

Output from `Get-LatestUpdate` can be filtered to find updates for a specific processor architecture or Windows version. For example, to filter for only the 32-bit version of Windows 10, use the following syntax:

```powershell
Get-LatestUpdate | Where-Object { $_.Arch -eq "x86" }
```

This will return output similar to the following:

```powershell
KB        Arch  Version Note                                                                                         URL
--        ----  ------- ----                                                                                         ---
KB4480116 x86   1809     2019-01 Cumulative Update for Windows 10 Version 1809 for x86-based Systems (KB4480116)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480116-x86_001457768574e3a4f0289c6a958d6680ee1fc90b.msu
```

`Get-LatestUpdate` will return updates for both Windows 10 x64 and Windows Server 2016 / Windows Server 2019 / Windows Server Semi Annual Channel. In this case, output will look similar to the following, where two entires in the array will both point to the same update URL.

```powershell
KB        Arch  Version Note                                                                                         URL
--        ----  ------- ----                                                                                         ---
KB4480116 x64   1809     2019-01 Cumulative Update for Windows Server 2019 for x64-based Systems (KB4480116)       http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480116-x64_4c8672ed7ce1d839421a36c681f9d3f64c31fe37.msu
KB4480116 x64   1809     2019-01 Cumulative Update for Windows 10 Version 1809 for x64-based Systems (KB4480116)   http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/01/windows10.0-kb4480116-x64_4c8672ed7ce1d839421a36c681f9d3f64c31fe37.msu
```

If this output is passed to `Save-LatestUpdate`, the update package will only be downloaded once; however, if you would still like to filter for a single x64 update, the following syntax could be used:

```powershell
Get-LatestUpdate | Where-Object { ($_.Arch -eq "x64") -and ($_.Version -like "*Windows 10*") }
```

or

```powershell
Get-LatestUpdate | Where-Object { $_.Arch -eq "x64" } | Sort-Object -Property Url -Unique
```
