# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $manifest = "$env:APPVEYOR_BUILD_FOLDER\ApplicationControl\ApplicationControl.psd1"
    $module = "$env:APPVEYOR_BUILD_FOLDER\ApplicationControl\ApplicationControl.psm1"
}
Else {
    # Local Testing 
    $manifest = "$(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)\..\ApplicationControl\ApplicationControl.psd1"
    $module = "$(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)\..\ApplicationControl\ApplicationControl.psm1"
}

Describe 'Module Metadata Validation' {      
    It 'Script fileinfo should be OK' {
        {Test-ModuleManifest $manifest -ErrorAction Stop} | Should Not Throw
    }   
    It 'Import module should be OK' {
        {Import-Module $module -Force -ErrorAction Stop} | Should Not Throw
    }
}