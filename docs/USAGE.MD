# Installing the Module

## Install from the PowerShell Gallery

The LatestUpdate module is published to the PowerShell Gallery and can be found here: [LatestUpdate](https://www.powershellgallery.com/packages/LatestUpdate/). The module can be installed from the gallery with:

```powershell
Install-Module -Name LatestUpdate
Import-Module -Name LatestUpdate
```

### Updating the Module

If you have installed a previous version of the module from the gallery, you can install the latest update with the `-Force` parameter:

```powershell
Install-Module -Name LatestUpdate -Force
```

## Manual Installation from the Repository

The module can be downloaded from the [GitHub source repository](https://github.com/aaronparker/LatestUpdate) and includes the module in the `LatestUpdate` folder. The folder needs to be installed into one of your PowerShell Module Paths. To see the full list of available PowerShell Module paths, use `$env:PSModulePath.split(';')` in a PowerShell console.

Common PowerShell module paths include:

* Current User: `%USERPROFILE%\Documents\WindowsPowerShell\Modules\`
* All Users: `%ProgramFiles%\WindowsPowerShell\Modules\`
* OneDrive: `$env:OneDrive\Documents\WindowsPowerShell\Modules\`

To install from the repository

1. Download the `master branch` to your workstation.
2. Copy the contents of the LatestUpdate folder onto your workstation into the desired PowerShell Module path.
3. Open a Powershell console with the Run as Administrator option.
4. Run `Set-ExecutionPolicy` using the parameter `RemoteSigned` or `Bypass`.

Once installation is complete, you can validate that the module exists by running `Get-Module -ListAvailable LatestUpdate`. To use the module, load it with:

```powershell
Import-Module LatestUpdate
```

# Using the Module

To use the module, we follow 3 tasks:

1. Get the latest update with Get-LatestUpdate
2. Download the update/s with Save-LatestUpdate
3. Optionally import the update/s into an MDT deployment share

## Get the Latest Update

`Get-LatestUpdate` retrieves the latest update from the Windows 10 Update History page at [https://support.microsoft.com/en-us/help/4043454](https://support.microsoft.com/en-us/help/4043454). Run `Get-LatestUpdate` with no additional switches to return the latest update for the most recent Windows 10 x64 build.

```powershell
PS C:\> Get-LatestUpdate
```

This returns the most recent update - depending on the current builds of Windows 10 and Windows Server, you could see a single update listed, or two updates - one for Windows 10 and another for Windows Server (if the builds are the same, both will be returned.)

To return the latest cumulative update for a specific build or processor architecture of Windows, use the following examples:

Return the cumulative update for Windows 10 1607:

```powershell
PS C:\> Get-LatestUpdate -WindowsVersion Windows10 -Build 14393
```

Return the cumulative update for latest release of Windows 10 x86:

```powershell
PS C:\> Get-LatestUpdate -WindowsVersion Windows10 -Architecture x86
```

## Operating System Support

Updates for the following operating systems can be returned:

* Windows 10 and Windows Server (including the available builds). Returns the latest Cumulative update for these versions of Windows.
* Windows 8.1 and Windows Server 2012 R2. Returns the latest Monthly Rollup for these version of Windows.
* Windows 7 and Windows Server 2008 R2. Returns the latest Monthly Rollup for these version of Windows.

### Filtering for Windows versions

Returning updates for specific versions, builds and processor architectures differs between Windows 10 and Windows 8.1/7. By default, updates for Windows 10 are returned.

* `-WindowsVersion`: use to specific the version of Windows to search for updates. Windows10, Windows8 and Windows7
* `-Build`: only available with '-WindowsVersion Windows10'. Specify a build number - '17134', '16299', '15063', '14393', '10586', '10240'.
* `-Architecture`: Returned the desired processor architecture with x86 and x64

## Download the Latest Update

`Save-LatestUpdate` is used to download the update or updates returned from `Get-LatestUpdate` to a local folder.

Often updates for multiple editions of Windows are returned; however, in each case these should be exactly the same update. For example, `Get-LatestUpate -WindowsVersion Windows7` will return updates for Windows 7 x64 and Windows Server 2008 R2, but these updates are the same for both operating systems. Where the updates point to the same URL, `Save-LatestUpdate` will filter the updates and download them once.

On Windows `Save-LatestUpdate` uses BITS to transfer the update locally for a robust download. Where BITS is not available, `Invoke-WebRequest` is used.

The following example, will download the latest cumulative update for the current release of Windows 10 x64:

```powershell
$Updates = Get-LatestUpdate
Save-LatestUpdate -Updates $Updates -Path "C:\Temp\Updates"
```

To download update for a specific version and architecture of Windows, modify the parameters for `Get-LatestUpdate`.

```powershell
$Updates = Get-LatestUpdate -WindowsVersion Windows8 -Architecture x86
Save-LatestUpdate -Updates $Updates -Path "C:\Temp\Updates"
```

This can be simplified to a one-line command that will get the latest update and download it to the current folder.

```powershell
Get-LatestUpdate | Save-LatestUpdate
```

## Import the Latest Update into MDT

Now that the cumulative update has been downloaded, you can import it into an MDT deployment share with `Import-LatestUpdate`. This requires the Microsoft Deployment Toolkit Workbench to be installed on the local machine (and therefore requires Windows).

The following example will retrieve the latest update and download it locally and finally import the update into the Packages node in a target MDT deployment share.

```powershell
$Updates = Get-LatestUpdate
Save-LatestUpdate -Updates $Updates -Path "C:\Temp\Updates"
Import-LatestUpdate -UpdatePath "C:\Temp\Updates" -SharePath "\\server\share"
```
