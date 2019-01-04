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
                -Value (Get-RxString -String $idItem.Note -RegEx "\s+([a-zA-Z0-9]+)-based")
            $newItem | Add-Member -type NoteProperty -Name 'Note' -Value $idItem.Note
            $newItem | Add-Member -type NoteProperty -Name 'URL' -Value $url
            $output += $newItem
        }
    }
    Write-Output $output
}
