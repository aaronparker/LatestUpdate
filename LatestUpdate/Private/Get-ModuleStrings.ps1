Function Get-ModuleStrings {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
        [System.String] $Path = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "LatestUpdate.json")
    )
    
    try {
        $content = Get-Content -Path $Path -Raw -ErrorAction SilentlyContinue
    }
    catch [System.Exception] {
        Write-Warning -Message "Failed to read module strings from $Path."
        Throw $_.Exception.Message
    }

    try {
        $object = $content | ConvertFrom-Json -AsHashtable -ErrorAction SilentlyContinue
    }
    catch [System.Exception] {
        Write-Warning -Message "Failed to convert strings to required object."
        Throw $_.Exception.Message
    }
    finally {
        If ($Null -ne $object) {
            Write-Output -InputObject $object
        }
    }
}
