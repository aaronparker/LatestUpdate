Function Add-Property {
    <#
        .SYNOPSIS
            Adds a property to a PSObject by querying another property
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Property,

        [Parameter(Mandatory = $True, Position = 2, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $NewPropertyName,

        [Parameter(Mandatory = $True, Position = 3, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchPattern
    )

    ForEach ($object in $InputObject) {
        $value = $object | Select-Object -ExpandProperty $Property | `
            Select-String -AllMatches -Pattern $MatchPattern | `
            ForEach-Object { $_.Matches.Value }
        If ($value.Count -ge 2) {
            $value = $value | Select-Object -Last 1
        }
        $object | Add-Member -NotePropertyName $NewPropertyName -NotePropertyValue $value
        Write-Output -InputObject $object
    }
}
