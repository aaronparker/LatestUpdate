# Get the Latest Update

`Get-LatestUpdate` retrieves the latest update from the Windows 10 Update History page at [https://support.microsoft.com/en-us/help/4043454](https://support.microsoft.com/en-us/help/4043454). Run `Get-LatestUpdate` with no additional switches to return the latest update for the most recent Windows 10 x64 build.

```powershell
PS C:\> Get-LatestUpdate
```

This returns the most recent update - depending on the current builds of Windows 10 and Windows Server, you could see a single update listed, or two updates - one for Windows 10 and another for Windows Server (if the builds are the same, both will be returned.)

To return the latest cumulative update for a specific build or processor architecture of Windows, use the following examples:

Return the cumulative update for Windows 10 1607:

```powershell
PS C:\> Get-LatestUpdate -WindowsVersion Windows10 -Build 14393
```

Return the cumulative update for latest release of Windows 10 x86:

```powershell
PS C:\> Get-LatestUpdate -WindowsVersion Windows10 -Architecture x86
```

Return the cumulative update for latest release of Windows 10 1709, x86:

```powershell
PS C:\> Get-LatestUpdate -WindowsVersion Windows10 -Build 16299 -Architecture x86
```

## Operating System Support

Updates for the following operating systems can be returned:

* Windows 10 and Windows Server (including the available builds). Returns the latest Cumulative update for these versions of Windows.
* Windows 8.1 and Windows Server 2012 R2. Returns the latest Monthly Rollup for these version of Windows.
* Windows 7 and Windows Server 2008 R2. Returns the latest Monthly Rollup for these version of Windows.

### Filtering for Windows versions

Returning updates for specific versions, builds and processor architectures differs between Windows 10 and Windows 8.1/7. By default, updates for Windows 10 are returned.

* `-WindowsVersion`: use to specific the version of Windows to search for updates. Windows10, Windows8 and Windows7
* `-Build`: only available with '-WindowsVersion Windows10'. Specify a build number - '17134', '16299', '15063', '14393', '10586', '10240'.
* `-Architecture`: Returned the desired processor architecture with x86 and x64
