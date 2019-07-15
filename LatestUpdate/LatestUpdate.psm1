<#
    .SYNOPSIS
        LatestUpdate script to initiate the module
#>
[CmdletBinding()]
Param ()

#region Get public and private function definition files
$publicRoot = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$privateRoot = Join-Path -Path $PSScriptRoot -ChildPath "Private"
$public = @( Get-ChildItem -Path (Join-Path $publicRoot "*.ps1") -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path (Join-Path $privateRoot "*.ps1") -ErrorAction SilentlyContinue )

# Dot source the files
ForEach ($import in @($public + $private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Warning -Message "Failed to import function $($import.fullname)."
        Throw $_.Exception.Message
    }
}

# Export the public modules and aliases
Export-ModuleMember -Function $public.Basename -Alias *
#endregion

# Get module strings
$script:resourceStrings = Get-ModuleResource

#region Dynamic autocompletion values for function parameters extracted from the LatestUpdate.json
$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:resourceStrings.ParameterValues.Windows10Versions
}
Register-ArgumentCompleter -CommandName Get-LatestServicingStackUpdate -ParameterName Version -ScriptBlock $scriptBlock
Register-ArgumentCompleter -CommandName Get-LatestCumulativeUpdate -ParameterName Version -ScriptBlock $scriptBlock
Register-ArgumentCompleter -CommandName Get-LatestAdobeFlashUpdate -ParameterName Version -ScriptBlock $scriptBlock

$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:resourceStrings.ParameterValues.VersionsAll
}
Register-ArgumentCompleter -CommandName Get-LatestServicingStackUpdate -ParameterName OperatingSystem -ScriptBlock $scriptBlock

$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:resourceStrings.ParameterValues.Versions108
}
Register-ArgumentCompleter -CommandName Get-LatestAdobeFlashUpdate -ParameterName OperatingSystem -ScriptBlock $scriptBlock

$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:resourceStrings.ParameterValues.Versions10
}
Register-ArgumentCompleter -CommandName Get-LatestCumulativeUpdate -ParameterName OperatingSystem -ScriptBlock $scriptBlock

$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:resourceStrings.ParameterValues.Versions87
}
Register-ArgumentCompleter -CommandName Get-LatestMonthlyRollup -ParameterName OperatingSystem -ScriptBlock $scriptBlock

$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $script:resourceStrings.ParameterValues.VersionsComplete
}
Register-ArgumentCompleter -CommandName Get-LatestNetFrameworkUpdate -ParameterName OperatingSystem -ScriptBlock $scriptBlock
#endregion

#region Dyamic ValidateSet for parameters, required PowerShell Core
<#
Class Windows10Versions : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {    
        $Windows10Versions = $script:resourceStrings.ParameterValues.Windows10Versions
    return $Windows10Versions
    }
}

Class Versions10 : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {    
        $Versions10 = $script:resourceStrings.ParameterValues.Versions10
    return $Versions10
    }
}#>
#endregion