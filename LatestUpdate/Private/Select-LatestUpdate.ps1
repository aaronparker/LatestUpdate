Function Select-LatestUpdate {
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [parameter(Mandatory = $True, ValueFromPipeline = $True)]
        $Updates
    )
    Begin { 
        $MaxObject = $Null
        $MaxValue = [version]::new("0.0")
    }
    Process {
        ForEach ( $Update in $Updates ) {
            Select-String -InputObject $Update -AllMatches -Pattern "(\d+\.)?(\d+\.)?(\d+\.)?(\*|\d+)" |
                ForEach-Object { $_.matches.value } |
                ForEach-Object { $_ -as [version] } |
                ForEach-Object { If ( $_ -gt $MaxValue ) { $MaxObject = $Update; $MaxValue = $_ } }
        }
    }
    End { 
        $MaxObject | Write-Output 
    }
}