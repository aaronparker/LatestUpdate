Function Test-UpdateParameter {
    # Validate Update parameter which could be a string or a PSCustomObject passed from Get-LatestUpdate.ps1
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipelineByPropertyName = $True)]
        $Param
    )
    [String]$UpdatePath = $Param
    If ($Path -is [PSCustomObject]) {
        [String]$UpdatePath = $Param.Path
    } 
    # Test the path to ensure it exists
    If (!(Test-Path -Path $UpdatePath -PathType 'Container' -ErrorAction SilentlyContinue )) {
        [bool]$UpdatePath = $False
    }
    $UpdatePath = $UpdatePath.TrimEnd("\")
    Return $UpdatePath
}