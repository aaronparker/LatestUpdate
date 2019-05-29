<#
    .SYNOPSIS
        AppVeyor build script.
#>

If (Get-Variable -Name projectRoot -ErrorAction SilentlyContinue) {

}
Else {
    Write-Warning -Message "Required variable does not exist: projectRoot."
}
