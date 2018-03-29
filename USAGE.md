# Get and Import Update Packages
Get updates for Windows 10 and Windows Server 2016 for querying and importing into an MDT deployment share. Schedule to keep your deployment share up to date.

Updates are queried from the [Windows 10 and Windows Server 2016 update history](https://support.microsoft.com/en-ph/help/4000825/windows-10-windows-server-2016-update-history) page.

## Get-LatestUpdate.ps1
Originally forked from [https://gist.github.com/keithga/1ad0abd1f7ba6e2f8aff63d94ab03048](https://gist.github.com/keithga/1ad0abd1f7ba6e2f8aff63d94ab03048).

Queries JSON from Microsoft to determine the latest Windows 10 updates. Returns an object that lists details of the update. Optionally download the update to a local folder.

This script supports the following parameters:

### PARAMETER SearchString
Specify a specific search string to change the target update behaviour. The default will only download Cumulative updates for x64.

### PARAMETER Download
Required to download the enumerated update.

### PARAMETER Path
Specify the path to download the updates to, otherwise the current folder will be used.

### Examples
Enumerate the latest Cumulative Update for Windows 10 x86 (Semi-Annual Channel)

        .\Get-LatestUpdate.ps1 -SearchString 'Cumulative.*x86'

Enumerate the latest Cumulative Update for Windows Server 2016

        .\Get-LatestUpdate.ps1 -SearchString 'Cumulative.*Server.*x64' -Build 14393

Enumerate the latest Windows 10 Cumulative Update for build 14393 and download it.

        .\Get-LatestUpdate.ps1 -Download -Build 14393

Enumerate the latest Windows 10 Cumulative Update (Semi-Annual Channel) and download to C:\Updates.

        .\Get-LatestUpdate.ps1 -Download -Path C:\Updates


## Import-Update.ps1
Imports updates from a specified folder into an MDT deployment share. Takes output via the pipeline from Get-LatestUpdate.ps1.

### PARAMETER UpdatePath
The folder containing the updates to import into the MDT deployment share.

### PARAMETER PathPath
Specify the path to the MDT deployment share.

### PARAMETER PackagePath
A folder path to import into under the Packages folder in MDT.

### PARAMETER Clean
Before importing the latest updates into the target path, remove any existing update package.

### Examples
Import the latest update gathered from Get-LatestUpdate.ps1 into the deployment share \\server\reference under 'Packages\Windows 10'.

         .\Get-LatestUpdate.ps1 -Download -Path C:\Updates | .\Import-Update.ps1 -SharePath \\server\reference -PackagePath 'Windows 10'
        
Import the latest update stored in C:\Updates into the deployment share \\server\reference. Remove all existing packages first. Show verbose output.

         .\Import-Update.ps1 -UpdatePath C:\Updates -SharePath \\server\reference -Clean -Verbose
        
Import the latest update stored in C:\Updates into the deployment share \\server\reference under 'Packages\Windows 10'.

         .\Import-Update.ps1 -UpdatePath C:\Updates -SharePath \\server\reference -PackagePath 'Windows 10'
