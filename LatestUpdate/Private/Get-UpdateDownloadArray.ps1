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
        [PSCustomObject] $IdTable
    )

    # RegEx strings
    [string] $rxArch = "\s+([a-zA-Z0-9]+)-based"
    [regex] $rx10 = "([1-2][0-9][0-1][0-9])\s"
    [regex] $rx2012 = "Windows Server 2012(?!\sR2)"

    $output = @()
    ForEach ($idItem in $IdTable) {
        try {
            Write-Verbose -Message "Checking Microsoft Update Catalog for Id: $($idItem.id)."
            $post = @{ size = 0; updateID = $idItem.id; uidInfo = $idItem.id } | ConvertTo-Json -Compress
            $postBody = @{ updateIDs = "[$post]" }
            $url = Invoke-WebRequest -Uri 'http://www.catalog.update.microsoft.com/DownloadDialog.aspx' `
                -Method Post -Body $postBody -UseBasicParsing -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty Content |
                Select-String -AllMatches -Pattern "(http[s]?\://download\.windowsupdate\.com\/[^\'\""]*)" | 
                ForEach-Object { $_.matches.value }
        }
        catch {
            Throw $_
            Write-Warning "Failed to parse Microsoft Update Catalog for Id: $($idItem.id)."
            Break
        }
        finally {
            Write-Verbose -Message "Adding $url to output."
            $newItem = New-Object PSObject
            $newItem | Add-Member -type NoteProperty -Name 'KB' -Value $idItem.KB

            # Add custom version note and check architecture based on description returned from page
            $arch = Get-RxString -String $idItem.Note -RegEx $rxArch
            If ($idItem.Note -match "Windows 10.*") {
                $Version = Get-RxString -String $idItem.Note -RegEx $rx10
                If ($Null -eq $arch) { $arch = "x86" }
            }
            ElseIf ($idItem.Note -match "Windows Server 2016") {
                $Version = "1607"
                If ($Null -eq $arch) { $arch = "x64" }
            }
            ElseIf ($idItem.Note -match $rx2012) {
                $Version = "2012"
                If ($Null -eq $arch) { $arch = "x64" }
            }
            ElseIf ($idItem.Note -match "Windows Server 2012 R2") {
                $Version = "2012R2"
                If ($Null -eq $arch) { $arch = "x64" }
            }
            ElseIf ($idItem.Note -match "Windows 8.1") {
                $Version = "8.1"
                If ($Null -eq $arch) { $arch = "x86" }
            }
            ElseIf ($idItem.Note -match "Windows Embedded 8 Standard") {
                $Version = "8Embedded"
                If ($Null -eq $arch) { $arch = "x86" }
            }
            ElseIf ($idItem.Note -match "Windows Server 2008 R2") {
                $Version = "2008R2"
                If ($Null -eq $arch) { $arch = "x64" }
            }
            ElseIf ($idItem.Note -match "Windows 7") {
                $Version = "7"
                If ($Null -eq $arch) { $arch = "x86" }
            }
            ElseIf ($idItem.Note -match "Windows Embedded Standard 7") {
                $Version = "7Embedded"
                If ($Null -eq $arch) { $arch = "x86" }
            }
            $newItem | Add-Member -type NoteProperty -Name 'Arch' -Value $arch
            $newItem | Add-Member -type NoteProperty -Name 'Version' -Value $Version

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
