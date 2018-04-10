# LatestUpdate

[![Build status][appveyor-badge]][appveyor-build]
[![PowerShell Gallery][psgallery-badge]][psgallery]
[![PowerShell Gallery Version][psgallery-version-badge][psgallery-version]
[![GitHub Release][github-release-badge]][github-release]

## About

This repository is a module for retrieving the latest Cumulative Update for Windows 10 / Windows Server builds, downloading the update file and importing it into a Microsoft Deployment Toolkit deployment share for speeding up creating reference images or Windows deployments. Windows Server 2012 R2, Windows 8.1, Windows Server 2008 R2 and Windows 7 Monthly Updates can also be queried for and downloaded.

Importing a cumulative update into [the Packages nodes in an MDT share](https://docs.microsoft.com/en-us/sccm/mdt/use-the-mdt#ConfiguringPackagesintheDeploymentWorkbench) enables updates during the offline phase of Windows setup, speeding up an installation of Windows. Updates could also be [applied directly to a WIM](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-operating-system-package-servicing-command-line-options).

This module is a re-write of the Update scripts found here: [https://github.com/aaronparker/MDT/tree/master/Updates](https://github.com/aaronparker/MDT/tree/master/Updates). Re-writing them as a PowerShell module enables better code management and publishing to the PowerShell Gallery for easier installation with `Install-Module`.

## Supported Platforms

LatestUpdate supports PowerShell 5.0 and above and is tested on macOS, Windows 10 and Windows Server 2016. Some basic testing has been done on Windows 7 with WMF 5.1. If you are running an earlier version of PowerShell, update to the latest release of the [Windows Management Framework](https://docs.microsoft.com/en-us/powershell/wmf/readme) or please use the [previous scripts](https://github.com/aaronparker/MDT/tree/master/Updates) instead.

### PowerShell Core

`Get-LatestUpdate` and `Save-LatestUpdate` support PowerShell Core; however, because `Import-LatestUpdate` requires the MDT Workbench, full support for PowerShell Core will depend on Microsoft updating the MDT PowerShell module to support it.

## Usage

See [Usage](USAGE.MD) for details on using the LatestUpdate module.

[appveyor-badge]: https://ci.appveyor.com/api/projects/status/s4g24puifpegq7kf/branch/master?svg=true
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/latestupdate/
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/latestupdate.svg
[psgallery]: https://www.powershellgallery.com/packages/latestupdate
[psgallery-version-badge]: https://img.shields.io/powershellgallery/v/LatestUpdate.svg
[psgallery-version]: https://www.powershellgallery.com/packages/latestupdate
