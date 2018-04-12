# Import the Latest Update into MDT

Now that the cumulative update has been downloaded, you can import it into an MDT deployment share with `Import-LatestUpdate`. This requires the Microsoft Deployment Toolkit Workbench to be installed on the local machine (and therefore requires Windows).

The following example will retrieve the latest update and download it locally and finally import the update into the Packages node in a target MDT deployment share.

```powershell
$Updates = Get-LatestUpdate
Save-LatestUpdate -Updates $Updates -Path "C:\Temp\Updates"
Import-LatestUpdate -UpdatePath "C:\Temp\Updates" -SharePath "\\server\share"
```
