Function Select-LatestUpdate {
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [parameter(Mandatory = $True, ValueFromPipeline = $True)]
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