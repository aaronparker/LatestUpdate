Function Select-LatestUpdate {
    <#
    .SYNOPSIS
        Selects the latest update build number.

    .DESCRIPTION
        Selects the latest update build number from the update JSON at https://support.microsoft.com/app/content/api/content/asset/en-us/4000816.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy
    
        Original script: Copyright Keith Garner, All rights reserved.
        Forked from: https://gist.github.com/keithga/1ad0abd1f7ba6e2f8aff63d94ab03048
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="MaxObj is used more than once.")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([String])]
    Param(
        [parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        $Updates
    )
    Begin {
        $MaxObj = $Null
        $MaxValue = [version]::new("0.0")
    }
    Process {
        ForEach ( $Update in $Updates ) {
            Select-String -InputObject $Update -AllMatches -Pattern "(\d+\.)?(\d+\.)?(\d+\.)?(\*|\d+)" |
                ForEach-Object { $_.matches.value } |
                ForEach-Object { $_ -as [version] } |
                ForEach-Object { If ( $_ -gt $MaxValue ) { $MaxObj += $Update; $MaxValue = $_ } }
        }
    }
    End { 
        Write-Output $MaxObj
    }
}