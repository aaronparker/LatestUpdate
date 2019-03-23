Function Get-UpdateDownloadArray {
    <#
        .SYNOPSIS
            Constructs a table with KB article, Update Id number and Update description from provided HTML links

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Links
            An object containing links filtered from a HTML object.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject] $IdTable
    )

    # Strings
    [string] $win10 = "Windows 10.*"
    [string] $rxArch = "\s+([a-zA-Z0-9]+)-based"
    [regex] $rx10 = "([1-2][0-9][0-1][0-9])\s"
    # [regex] $rx2012 = "Windows Server 2012(?!\sR2)"
    $editions = @{
        "Windows Server 2019"         = "1809"
        "Windows Server 2016"         = "1607"
        "Windows Server 2012 R2"      = "2012 R2"
        "Windows Server 2012(?!\sR2)" = "2012"
        "Windows Server 2008 R2"      = "2008R2"
        "Windows 8.1"                 = "8.1"
        "Windows Embedded 8 Standard" = "8Embedded"
        "Windows 7"                   = "7"
        "Windows Embedded Standard 7" = "7Embedded"
    }
    $architectures = @{
        "Windows Server 2019"         = "x64"
        "Windows Server 2016"         = "x64"
        "Windows Server 2012 R2"      = "x64"
        "Windows Server 2012(?!\sR2)" = "x64"
        "Windows Server 2008 R2"      = "x64"        
        "Windows 8.1"                 = "x86"
        "Windows Embedded 8 Standard" = "x86"
        "Windows 7"                   = "x86"
        "Windows Embedded Standard 7" = "x86"
    }
        # 

    $output = @()
    ForEach ($idItem in $IdTable) {
        try {
            Write-Verbose -Message "Checking Microsoft Update Catalog for Id: $($idItem.id)."
            $post = @{ size = 0; updateID = $idItem.id; uidInfo = $idItem.id } | ConvertTo-Json -Compress
            $postBody = @{ updateIDs = "[$post]" }
            $url = Invoke-WebRequest -Uri 'http://www.catalog.update.microsoft.com/DownloadDialog.aspx' `
                -Method Post -Body $postBody -UseBasicParsing -ErrorAction SilentlyContinue | `
            Select-Object -ExpandProperty Content | `
            Select-String -AllMatches -Pattern "(http[s]?\://download\.windowsupdate\.com\/[^\'\""]*)" | `
            ForEach-Object { $_.matches.value }
        }
        catch {
            Throw "Failed to parse Microsoft Update Catalog for Id: $($idItem.id)."
            Break
        }
        finally {
            Write-Verbose -Message "Adding $url to output."
            $newItem = New-Object PSCustomObject
            $newItem | Add-Member -type NoteProperty -Name 'KB' -Value $idItem.KB

            # Add custom version note and check architecture based on description returned from page
            $arch = Get-RxString -String $idItem.Note -RegEx $rxArch

            If ($idItem.Note -match $win10) {
                $version = Get-RxString -String $idItem.Note -RegEx $rx10
                If ($Null -eq $arch) { $arch = "x86" }
            }
            Else {
                ForEach ($key in $editions.Keys) {
                    If ($idItem.Note -match ([regex] $key)) {
                        Write-Verbose "Matched: $key"
                        $version = $editions[$key]
                        If ($Null -eq $arch) { $arch = $architectures[$key] }
                    }
                }
            }

            $newItem | Add-Member -type NoteProperty -Name 'Arch' -Value $arch
            $newItem | Add-Member -type NoteProperty -Name 'Version' -Value $version
            $newItem | Add-Member -type NoteProperty -Name 'Note' -Value $idItem.Note

            # Filter URL to ensure only .MSU updates are returned
            If (Test-PSCore) {
                $download = $url | Where-Object { (Split-Path -Path $_ -Extension) -match ".msu" }
            }
            Else {
                $download = $url | Where-Object { ([IO.Path]::GetExtension($_)) -match ".msu" }
            }
            $newItem | Add-Member -type NoteProperty -Name 'URL' -Value $download

            # Add item to the output array
            $output += $newItem
        }
    }

    Write-Output $output
}
