# LatestUpdate

[![Build status][appveyor-badge]][appveyor-build]

This is a module for retreiving the latest Cumulative Update for Windows 10 builds, downloading the update file and importing it into a Microsoft Deployment Toolkit deployment share for speeding up deployment of Windows 10 reference images or installs.

Importing the cumulative update into an MDT share, enables MDT to apply the update during the offline phase of Windows 10 setup, speeding up installation of Windows.

This is a re-write of the Update scripts found here: [https://github.com/aaronparker/MDT/tree/master/Updates](https://github.com/aaronparker/MDT/tree/master/Updates). Re-writing the scripts as a module enables better code management and publishing the module to the PowerShell Gallery for simpler installation.

[appveyor-badge]: https://ci.appveyor.com/api/projects/status/s4g24puifpegq7kf/branch/master?svg=true
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/latestupdate/
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/latestupdate.svg
[psgallery]: https://www.powershellgallery.com/packages/latestupdate
[gitbooks-badge]: https://www.gitbook.com/button/status/book/aaronparker/vcredist/
[gitbooks-build]: https://www.gitbook.com/book/aaronparker/vcredist
[github-release-badge]: https://img.shields.io/github/release/aaronparker/Install-VisualCRedistributables.svg
[github-release]: https://github.com/aaronparker/Install-VisualCRedistributables/releases/latest