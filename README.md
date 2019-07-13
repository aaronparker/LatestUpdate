# LatestUpdate

[![License][license-badge]][license]
[![GitHub Release][github-release-badge]][github-release]
[![PowerShell Gallery][psgallery-badge]][psgallery]
[![PowerShell Gallery Version][psgallery-version-badge]][psgallery]

[![Master build status][appveyor-badge]][appveyor-build]
[![Development build status][appveyor-badge-dev]][appveyor-build]

## About

A module for retrieving the latest Windows 10 / Windows Server 2016, 2019, Semi Annual Channel Cumulative Updates, Servicing Stack Updates, .NET Framework Cumulative Updates, the Monthly Rollups for 8.1 / 7 (and Windows Server 2012 R2, 2008 R2) and the latest Adobe Flash Player updates from the Microsoft Update History page. In addition, the module provides a function for downloading the update files locally.

Importing a cumulative update into [the Packages nodes in an MDT share](https://docs.microsoft.com/en-us/sccm/mdt/use-the-mdt#ConfiguringPackagesintheDeploymentWorkbench) enables updates during the offline phase of Windows setup, speeding up an installation of Windows. Updates can also be [applied directly to a WIM](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-operating-system-package-servicing-command-line-options).

## Documentation

Regularly updated documentation for the module is located at [https://docs.stealthpuppy.com/docs/latestupdate/](https://docs.stealthpuppy.com/docs/latestupdate/)

## Supported Platforms

LatestUpdate supports PowerShell 5.0 and above and is tested on macOS, Windows 10 and Windows Server 2016. Some basic testing has been done on Windows 7 with WMF 5.1. If you are running an earlier version of PowerShell, update to the latest release of the [Windows Management Framework](https://docs.microsoft.com/en-us/skypeforbusiness/set-up-your-computer-for-windows-powershell/download-and-install-windows-powershell-5-1).

### PowerShell Core

Verison 3 of `LatestUpdate` has been re-written and includes full support for PowerShell Core.

## Acknowledgements

This module uses code and inspiration from these sources:

* [Keith Garner](https://twitter.com/keithga1) - [gist](https://gist.github.com/keithga/1ad0abd1f7ba6e2f8aff63d94ab03048)
* [Nickolaj Andersen](https://twitter.com/NickolajA) - [script](https://github.com/SCConfigMgr/ConfigMgr/blob/master/Software%20Updates/Invoke-MSLatestUpdateDownload.ps1)

[appveyor-badge]: https://ci.appveyor.com/api/projects/status/s4g24puifpegq7kf/branch/master?svg=true&failingText=master%20-%20failing&passingText=master%20-%20OK&logo=PowerShell&style=flat-square
[appveyor-badge-dev]: https://ci.appveyor.com/api/projects/status/s4g24puifpegq7kf/branch/development?svg=true&failingText=development%20-%20failing&passingText=development%20-%20OK&logo=PowerShell&style=flat-square
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/latestupdate/
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/latestupdate.svg?logo=PowerShell&style=flat-square
[psgallery]: https://www.powershellgallery.com/packages/latestupdate
[psgallery-version-badge]: https://img.shields.io/powershellgallery/v/LatestUpdate.svg?logo=PowerShell&style=flat-square
[psgallery-version]: https://www.powershellgallery.com/packages/latestupdate
[github-release-badge]: https://img.shields.io/github/release/aaronparker/LatestUpdate.svg?logo=github&style=flat-square
[github-release]: https://github.com/aaronparker/LatestUpdate/releases/latest
[license-badge]: https://img.shields.io/github/license/aaronparker/latestupdate.svg?style=flat-square
[license]: https://github.com/aaronparker/latestupdate/blob/master/LICENSE
