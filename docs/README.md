# LatestUpdate

This repository is a module for retrieving the latest Cumulative Update and Adobe Flash Player updates for Windows 10 / Windows Server builds from the Microsoft Update Catalog. The module also supports the latest Monthly Rollups for Windows 8.1 / Windows Server 2012 R2, Windows 7 / Windows Server 2008 R2.

In addition, it provides functions for downloading the update files and importing them into a Microsoft Deployment Toolkit deployment share for speeding the creation of reference images or Windows deployments.

The module queries the Windows update history feeds and returns details for the latest update including the download URL from the Microsoft Update Catalog, making it easy to find the latest update for your target operating system.

* [Windows 10 and Windows Server update history](https://support.microsoft.com/en-au/help/4043454)
* [Windows 8.1 and Windows Server 2012 R2 update history](https://support.microsoft.com/en-us/help/4009470)
* [Windows 7 SP1 and Windows Server 2008 R2 SP1 update history](https://support.microsoft.com/en-au/help/4009469)

## Why

Importing a cumulative update into [the Packages nodes in an MDT share](https://docs.microsoft.com/en-us/sccm/mdt/use-the-mdt#ConfiguringPackagesintheDeploymentWorkbench) enables updates during the offline phase of Windows setup, speeding up an installation of Windows. This makes deploying Windows faster than if you were to rely soley on Windows Update or WSUS to apply the updates during operating system deployment.

Updates could also be [applied directly to a WIM](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-operating-system-package-servicing-command-line-options).

## History

This module is a re-write of the Update scripts found here: [https://github.com/aaronparker/MDT/tree/master/Updates](https://github.com/aaronparker/MDT/tree/master/Updates). Re-writing them as a PowerShell module enables better code management and publishing to the PowerShell Gallery for easier installation with `Install-Module`.
