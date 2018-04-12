# Supported Platforms

## Windows Verisons

LatestUpdate supports retrieving the latest Cumulative Update for Windows 10 / Windows Server builds. Additionally Monthly Updates for Windows Server 2012 R2, Windows 8.1, Windows Server 2008 R2 and Windows 7 are supported.

## PowerShell Editions

LatestUpdate supports PowerShell 5.0 and above with testing completed on macOS, Windows 10 and Windows Server 2016. Some testing has been performed on Windows 7 with WMF 5.1. If you are running an earlier version of PowerShell, update to the latest release of the [Windows Management Framework](https://docs.microsoft.com/en-us/powershell/wmf/readme) or please use the [previous scripts](https://github.com/aaronparker/MDT/tree/master/Updates) instead.

### PowerShell Core

`Get-LatestUpdate` and `Save-LatestUpdate` support PowerShell Core; however, because `Import-LatestUpdate` requires the MDT Workbench, full support for PowerShell Core will depend on Microsoft updating the MDT PowerShell module to support it.