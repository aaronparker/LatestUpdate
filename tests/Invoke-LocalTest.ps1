<#
    .SYNOPSIS
        Run local Pester tests avoiding large downloads
#>
[OutputType()]
Param ()

# Invoke Pester tests and upload results to AppVeyor
$res = Invoke-Pester -Path (Join-Path -Path $PWD -ChildPath "PublicFunctions.Tests.ps1") -PassThru -ExcludeTag "AppVeyor"
If ($res.FailedCount -gt 0) { Throw "$($res.FailedCount) tests failed." }
Write-Host ""
