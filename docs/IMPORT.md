# Import the Latest Update into MDT

Now that the cumulative update has been downloaded, you can import it into an MDT deployment share with `Import-LatestUpdate`. This requires the Microsoft Deployment Toolkit Workbench to be installed on the local machine (and therefore requires Windows).

The following example will retrieve the latest update and download it locally and finally import the update into the Packages node in a target MDT deployment share specified by `-DeployRoot`.

```powershell
$Updates = Get-LatestUpdate
Save-LatestUpdate -Updates $Updates -Path "C:\Temp\Updates"
Import-LatestUpdate -UpdatePath "C:\Temp\Updates" -DeployRoot "\\server\share"
```

## Removing Existing Packages

Any existing package can be removed from the target MDT Packages folder with the `-Clean` switch. If this switch is not specified, an update will be imported alongside any existing packages. When importing the next update, you may want to remove any existing outdated update.

The following example will import the update stored in `C:\Temp\Updates` into the deployment share `\\server\reference` under `Packages\Windows 10`. Any existing packages will be removed before the import.

```powershell
Import-LatestUpdate -UpdatePath "C:\Temp\Updates" -DeployRoot "\\server\reference" -PackagePath "Windows 10" -Clean
```
