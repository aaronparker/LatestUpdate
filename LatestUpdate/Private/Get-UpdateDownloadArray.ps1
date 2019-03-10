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
            $newItem | Add-Member -type NoteProperty -Name 'Arch' `
                -Value (Get-RxString -String $idItem.Note -RegEx $rxArch)

            # Add custom version note based on description returned from page
            If ($idItem.Note -match "Windows 10.*") {
                $Version = Get-RxString -String $idItem.Note -RegEx $rx10
            }
            ElseIf ($idItem.Note -match $rx2012) {
                $Version = "2012"
            }
            ElseIf ($idItem.Note -match "Windows Server 2012 R2") {
                $Version = "2012R2"
            }
            ElseIf ($idItem.Note -match "Windows 8.1") {
                $Version = "8.1"
            }
            ElseIf ($idItem.Note -match "Windows Embedded 8 Standard") {
                $Version = "8Embedded"
            }
            ElseIf ($idItem.Note -match "Windows Server 2008 R2") {
                $Version = "2008R2"
            }
            ElseIf ($idItem.Note -match "Windows 7") {
                $Version = "7"
            }
            ElseIf ($idItem.Note -match "Windows Embedded Standard 7") {
                $Version = "7Embedded"
            }
            $newItem | Add-Member -type NoteProperty -Name 'Version' -Value $Version

            $newItem | Add-Member -type NoteProperty -Name 'Note' -Value $idItem.Note

            # Filter URL to ensure only .MSU updates are returned
            $download = $url | Where-Object { (Split-Path -Path $_ -Extension) -match ".msu" }
            $newItem | Add-Member -type NoteProperty -Name 'URL' -Value $download

            $output += $newItem
        }
    }
    Write-Output $output
}
