# LatestUpdate

## About

LatestUpdate is a PowerShell module for retrieving the latest Cumulative Update for Windows 10 / Windows Server builds, downloading the update file and importing it into a Microsoft Deployment Toolkit deployment share for speeding up creating reference images or Windows deployments. Windows Server 2012 R2, Windows 8.1, Windows Server 2008 R2 and Windows 7 Monthly Updates can also be queried for and downloaded.

Importing a cumulative update into [the Packages nodes in an MDT share](https://docs.microsoft.com/en-us/sccm/mdt/use-the-mdt#ConfiguringPackagesintheDeploymentWorkbench) enables updates during the offline phase of Windows setup, speeding up an installation of Windows. Updates could also be [applied directly to a WIM](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-operating-system-package-servicing-command-line-options).

This module is a re-write of the Update scripts found here: [https://github.com/aaronparker/MDT/tree/master/Updates](https://github.com/aaronparker/MDT/tree/master/Updates). Re-writing them as a PowerShell module enables better code management and publishing to the PowerShell Gallery for easier installation with `Install-Module`.

## Supported Platforms

LatestUpdate supports PowerShell 5.0 and above with testing completed on macOS, Windows 10 and Windows Server 2016. Some testing has been performed on Windows 7 with WMF 5.1. If you are running an earlier version of PowerShell, update to the latest release of the [Windows Management Framework](https://docs.microsoft.com/en-us/powershell/wmf/readme) or please use the [previous scripts](https://github.com/aaronparker/MDT/tree/master/Updates) instead.

### PowerShell Core

`Get-LatestUpdate` and `Save-LatestUpdate` support PowerShell Core; however, because `Import-LatestUpdate` requires the MDT Workbench, full support for PowerShell Core will depend on Microsoft updating the MDT PowerShell module to support it.