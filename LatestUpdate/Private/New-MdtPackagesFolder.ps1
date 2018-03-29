Function New-MdtPackagesFolder {
    # Function to create a folder in the MDT Packages node
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [String]$Drive,

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String]$Path
    )
    [String]$Dest = "$($Drive):\Packages\$Path"
    If (!(Test-Path -Path $Dest -Type 'Container')) {
        Write-Verbose "Creating folder $Dest."
        Push-Location "$($Drive):\Packages"
        New-Item -Path "$($Drive):\Packages" -Enable "True" -Name $Path `
            -Comments "Created by 'Import-Update.ps1" `
            -ItemType "Folder"
        Pop-Location
    }
    Return $Dest
}