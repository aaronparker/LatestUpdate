# LatestUpdate

This is a module for retreiving the latest Cumulative Update for Windows 10 builds, downloading the update file and importing it into a Microsoft Deployment Toolkit deployment share for speeding up deployment of Windows 10 reference images or installs.

Importing the cumulative update into an MDT share, enables MDT to apply the update during the offline phase of Windows 10 setup, speeding up installation of Windows.

This is a re-write of the Update scripts found here: [https://github.com/aaronparker/MDT/tree/master/Updates](https://github.com/aaronparker/MDT/tree/master/Updates). Re-writing the scripts as a module enables better code management and publishing the module to the PowerShell Gallery for simpler installation.