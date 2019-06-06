Function ConvertTo-HashtableFromPSCustomObject { 
    Param ( 
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline)]
        [System.Management.Automation.PSObject[]] $InputObject 
    )
    
    Process { 
        ForEach ($object in $InputObject) { 
            $output = @{ }; 
            $object | Get-Member -MemberType *Property | ForEach-Object { $output.($_.name) = $object.($_.name); } 
            Write-Output -InputObject $output
        }
    }
}
