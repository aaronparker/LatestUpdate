<#
    .SYNOPSIS
        LatestUpdate script to initiate the module
#>
[CmdletBinding()]
Param ()

# Get public and private function definition files
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

# Export the Public modules
Export-ModuleMember -Function $public.Basename -Alias *

# Get module strings
$script:resourceStrings = Get-ModuleResource

# Dynamic autocompletion values
$scriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)    
    $script:resourceStrings = Get-ModuleResource
    $script:resourceStrings.VersionTable.Windows10Versions
}
Register-ArgumentCompleter -CommandName Get-LatestServicingStackUpdate -ParameterName Version -ScriptBlock $scriptBlock
Register-ArgumentCompleter -CommandName Get-LatestCumulativeUpdate -ParameterName Version -ScriptBlock $scriptBlock
Register-ArgumentCompleter -CommandName Get-LatestAdobeFlashUpdate -ParameterName Version -ScriptBlock $scriptBlock
