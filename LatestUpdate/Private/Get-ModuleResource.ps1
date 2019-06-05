Function Get-ModuleResource {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
        [System.String] $Path = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "LatestUpdate.json")
    )
    
    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand): read module resource strings from [$Path]"
        $content = Get-Content -Path $Path -Raw -ErrorAction SilentlyContinue
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read from: $Path."
        Throw $_.Exception.Message
    }

    try {
        $resourceStringsTable = $content | ConvertFrom-Json -AsHashtable -ErrorAction SilentlyContinue
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert strings to required object."
        Throw $_.Exception.Message
    }
    finally {
        If ($Null -ne $resourceStringsTable) {
            Write-Output -InputObject $resourceStringsTable
        }
    }
}
