Function Get-LatestFlash {
    <#
        .SYNOPSIS
            Get the latest Adobe Flash Player update for Windows.

        .DESCRIPTION

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/latestupdate

        .EXAMPLE
            Get-LatestFlash
        
            Description:
            Enumerate the latest Adobe Flash Player update for the support versions of Windows.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $False, Position = 0, HelpMessage = "Windows OS to search")]
        [ValidateNotNullOrEmpty()]
        [String] $OS
    )

    Begin {
        [String] $Feed = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/6ae59d69-36fc-8e4d-23dd-631d98bf74a9/atom'
        [regex] $Flash = ".*Adobe Flash Player.*"
    }

    Process {

        try {
            # Return the update feed
            $xml = Get-UpdateFeed -UpdateFeed $Feed
        }
        catch {
            Throw "Failed to return the update feed. Confirm feed is OK: $Feed"
            Break
        }
        
        # Find the most current date for the update
        [regex] $rxM = "(\d{4}-\d{2}-\d{2})"
        $date = $xml.feed.entry | Where-Object { $_.title -match $Flash } | Select-Object -ExpandProperty updated | `
            ForEach-Object { Get-RxString -String $_ -RegEx $rxM } | Sort-Object | Select-Object -Last 1

        # Return the KB published for that most current date
        $kbID = $xml.feed.entry | Where-Object { ($_.title -match $Flash) -and ($_.updated -match $date) } | Select-Object -ExpandProperty id `
            | ForEach-Object { $_.split(':') | Select-Object -Last 1 }

        If (($Null -eq $date) -or ($Null -eq $kbID)) {
            Write-Warning -Message "Failed to return usable Windows update content from the Microsoft feed."
            Write-Warning -Message "Microsoft appears to be returning different content for each request."
            Write-Warning -Message "Please check the feed content and try again later."
            Write-Warning -Message "Feed URI: $Feed"
            Break
        }
        Else {
            # Get the download link from Windows Update
            [String] $SearchString = "KB" + $kbID

            if ($OS) {
               $SearchString = $SearchString + " $OS"
            }

            $kbObj = Get-UpdateCatalogLink -SearchString $SearchString
            If ($Null -ne $kbObj) {
                # Contruct a table with KB, Id and Update description
                $idTable = Get-KbUpdateArray -Links $kbObj.Links -KB $kbID

                # Process the IdTable to get a new array with KB, Architecture, Note and URL for each download
                $downloadArray = Get-UpdateDownloadArray -IdTable $idTable
            }
        }
    }

    End {
        # Write the list of updates to the pipeline
        If ($Null -ne $downloadArray) {
            Write-Output ($downloadArray | Sort-Object -Property Version -Descending)
        }
    }
}
