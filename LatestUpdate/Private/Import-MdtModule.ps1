Function Import-MdtModule {
    <#
    .SYNOPSIS
        Imports the MDT PowerShell module.

    .DESCRIPTION
        Imports the MDT PowerShell module.

    .NOTES
    #>
    # If we can find the MDT PowerShell module, import it. Requires MDT console to be installed
    $MdtModule = "$((Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4").Install_Dir)bin\MicrosoftDeploymentToolkit.psd1"
    If (Test-Path -Path $MdtModule) {
        Try {            
            Import-Module -Name $MdtModule -ErrorAction SilentlyContinue
            Return $True
        }
        Catch {
            Throw "Could not load MDT PowerShell Module. Please make sure that the MDT console is installed correctly."
            Return $False
        }
    }
    Else {
        Throw "Cannot find the MDT PowerShell module. Is the MDT console installed?"
        Return $False
    }
}