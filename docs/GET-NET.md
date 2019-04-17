# Get the Latest .NET Framework cumulative Update

`Get-LatestNetFramework` retrieves the latest cumulative .NET Framework updates for the given OS from the Microsoft Update Catalog. Run `Get-LatestNetFramework -OS "Windows Server 2019"` to return the latest update.

```powershell
PS C:\> Get-LatestNetFramework -OS "Windows Server 2019"
```

## Output

`Get-LatestNetFramework -OS "Windows Server 2019" | Format-Table` returns the latest cumulative update for the given OS. This will look similar to output shown below.

```powershell

KB          Arch Version Note                                                                                                   URL
--          ---- ------- ----                                                                                                   ---
KBKB4489192 x64  1809    2019-03 Cumulative Update for .NET Framework 3.5 and 4.7.2 for Windows Server 2019 for x64 (KB4489192) http://download.windowsupdate.com/d/msdownload/update/software/updt/2019/03/windows10.0-kb4489192-x64_872afd1aabdc1ee545f0e654ac550997d9548aae.msu
```
