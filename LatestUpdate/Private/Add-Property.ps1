Function Add-Property {
    <#
        .SYNOPSIS
            Adds a property to a PSObject by querying another property
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Property,

        [Parameter(Mandatory = $True, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $NewPropertyName,

        [Parameter(Mandatory = $True, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchPattern
    )

    Process {
        ForEach ($object in $InputObject) {
            $value = $object | Select-Object -ExpandProperty $Property | `
                Select-String -AllMatches -Pattern $MatchPattern | `
                ForEach-Object { $_.Matches.Value }
        
            If ($value.Count -gt 1) {
                $value = $value | Select-Object -Last 1
            }
            If ($Null -ne $value) { $value = $value.Trim(" ") }

            $object | Add-Member -NotePropertyName $NewPropertyName -NotePropertyValue $value
            Write-Output -InputObject $object
        }
    }
}
