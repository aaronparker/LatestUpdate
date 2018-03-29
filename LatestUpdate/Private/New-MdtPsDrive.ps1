Function New-MdtPsDrive {
    If (Import-MdtModule) {
        $Drive = "DS001"
        If (Test-Path "$($Drive):") {
            Write-Verbose "Found existing MDT drive $Drive."
            Remove-PSDrive -Name $Drive -Force
        }
        New-PSDrive -Name $Drive -PSProvider MDTProvider -Root $SharePath
    }
    Else {
        Throw "Unable to map drive to the MDT deployment share."
    }
}