Function Import-MdtModule {
    <#
    .SYNOPSIS
        Imports the MDT PowerShell module.

    .DESCRIPTION
        Imports the MDT PowerShell module.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    #>
    # If we can find the MDT PowerShell module, import it. Requires MDT console to be installed
    $InstallDir = Get-ValidPath -Path $((Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4" -ErrorAction SilentlyContinue).Install_Dir)
    $MdtModule = "$($InstallDir)\bin\MicrosoftDeploymentToolkit.psd1"
        Try {            
            Import-Module -Name $MdtModule -ErrorAction SilentlyContinue
        }
        Catch {
            Throw "Could not load MDT PowerShell Module. Please make sure that the MDT Workbench is installed correctly."
        }
    Write-Output $?
}