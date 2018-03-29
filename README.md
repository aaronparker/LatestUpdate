# LatestUpdate

[![Build status][appveyor-badge]][appveyor-build]
[![PowerShell Gallery][psgallery-badge]][psgallery]
[![GitHub Release][github-release-badge]][github-release]

## About

This repository is a module for retrieving the latest Cumulative Update for Windows 10 builds, downloading the update file and importing it into a Microsoft Deployment Toolkit deployment share for speeding up deployment of Windows 10 reference images or installs.

Importing a cumulative update into [the Packages nodes in an MDT share](https://docs.microsoft.com/en-us/sccm/mdt/use-the-mdt#ConfiguringPackagesintheDeploymentWorkbench) enables updates during the offline phase of Windows 10 setup, speeding up an installation of Windows.

This module is a re-write of the Update scripts found here: [https://github.com/aaronparker/MDT/tree/master/Updates](https://github.com/aaronparker/MDT/tree/master/Updates). Re-writing them as a PowerShell module enables better code management and publishing to the PowerShell Gallery for easier installation with `Install-Module`.

## Supported Platforms

LatestUpdate will only support PowerShell 5.0 (and potentially PowerShell Core) and is tested on Windows 10 and Windows Server 2016. If you are running an earlier version of PowerShell, update to the latest release of the [Windows Management Framework](https://docs.microsoft.com/en-us/powershell/wmf/readme) or please use the [previous scripts](https://github.com/aaronparker/MDT/tree/master/Updates) instead.

### PowerShell Core

Support for PowerShell Core will be added in a future release; however, because `Import-LatestUpdate` requires the MDT Workbench, full support for PowerShell Core will depend on Microsoft updating the MDT PowerShell module to support it.

## Usage

See [Usage](USAGE.MD) for details on using the LatestUpdate module.

[appveyor-badge]: https://ci.appveyor.com/api/projects/status/s4g24puifpegq7kf/branch/master?svg=true
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/latestupdate/
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/latestupdate.svg
[psgallery]: https://www.powershellgallery.com/packages/latestupdate
[gitbooks-badge]: https://www.gitbook.com/button/status/book/aaronparker/latestupdate/
[gitbooks-build]: https://www.gitbook.com/book/aaronparker/latestupdate
[github-release-badge]: https://img.shields.io/github/release/aaronparker/LatestUpdate.svg
[github-release]: https://github.com/aaronparker/LatestUpdate/releases/latest