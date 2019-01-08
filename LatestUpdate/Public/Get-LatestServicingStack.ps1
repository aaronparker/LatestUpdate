Function Get-LatestServicingStack {
    <#
        .SYNOPSIS
            Get the latest Servicing Stack Update for Windows 10.

        .DESCRIPTION
            Returns the latest Servicing Stack Update for Windows 10 and corresponding Windows Server from the Microsoft Update Catalog by querying the Update History page.

            Get-LatestUpdate outputs the result as a table that can be passed to Save-LatestUpdate to download the update locally. Then do one or more of the following:
            - Import the update into an MDT share with Import-LatestUpdate to speed up deployment of Windows (reference images etc.)
            - Apply the update to an offline WIM using DISM
            - Deploy the update with ConfigMgr (if not using WSUS)

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK

        .PARAMETER Version
            Windows 10 version to return the Servicing Stack Update for. Use the Year Month notation for Windows 10 versions. Supports 1607+.
            
        .EXAMPLE
            Get-LatestServicingStack

            Description:
            Get the latest Servicing Stack Update for all supported Windows 10 and Windows Server versions.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $False, Position = 0, HelpMessage = "Windows 10 version to search")]
        [ValidateSet('1607', '1703', '1709', '1803', '1809')]
        [String[]] $Version = @('1607', '1703', '1709', '1803', '1809')
    )

    Begin {
        # Update RSS feed and search string
        [string] $Feed = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/6ae59d69-36fc-8e4d-23dd-631d98bf74a9/atom'
        [regex] $searchString = "Servicing stack update.*"

        # Return the XML from the feed and filter for the Servicing Stack Updates
        $xml = Get-UpdateFeed -UpdateFeed $Feed
        $servicingStacks = $xml.feed.entry | Where-Object { $_.title -match $searchString } | Select-Object title, id, updated

        # RegEx for month; Output array
        [regex] $rxM = "(\d{4}-\d{2}-\d{2})"
        $output = @()
    }

    Process {
        # Step through the servicing stack feed to find the latest KB article for each Windows 10 version
        ForEach ($vItem in $Version) {

            # Find the most current date for each entry for each Windows 10 version
            $date = $servicingStacks | Where-Object { $_.title -match $vItem } | Select-Object -ExpandProperty updated | `
                ForEach-Object { ([regex]::match($_, $rxM).Groups[1].Value) } | Sort-Object | Select-Object -Last 1

            # Return the KB published for that most current date
            $kbID = $servicingStacks | Where-Object { ($_.title -match $vItem) -and ($_.updated -match $date) } | Select-Object -ExpandProperty id `
                | ForEach-Object { $_.split(':') | Select-Object -Last 1 }

            # Multiple KBs could be returned, step through each
            ForEach ($id in $kbID) {

                # Read the for updates for that KB from the Microsoft Update Catalog
                $kbObj = Get-UpdateCatalogLink -KB $id
                If ($Null -ne $kbObj) {

                    # Contruct a table with KB, Id and Update description
                    $idTable = Get-KbUpdateArray -Links $kbObj.Links -KB $kbID

                    # Step through the ids for each update
                    ForEach ($idItem in $idTable) {
                        try {

                            # Grab the URL for each update
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
                            # Build an array for each update and add it to the output array
                            If ($url) {
                                Write-Verbose -Message "Adding $url to output."
                                $newItem = New-Object PSObject
                                $newItem | Add-Member -type NoteProperty -Name 'KB' -Value $idItem.KB
                                $newItem | Add-Member -type NoteProperty -Name 'Arch' `
                                    -Value (Get-RxString -String $idItem.Note -RegEx "\s+([a-zA-Z0-9]+)-based")
                                $newItem | Add-Member -type NoteProperty -Name 'Version' -Value $vItem
                                $newItem | Add-Member -type NoteProperty -Name 'Note' -Value $idItem.Note
                                $newItem | Add-Member -type NoteProperty -Name 'URL' -Value $url
                                $output += $newItem
                            }
                        }
                    }
                }
            }
        }
    }

    End {

        # Return the array of Servicing Stack Updates to the pipeline
        Write-Output ($output | Sort-Object -Property Version -Descending)
    }
}
