Function Get-LatestNETFramework {
    <#
        .SYNOPSIS
            Get the latest .NET Framework Cumulative update for Windows.

        .DESCRIPTION

        .NOTES
            Author: Gianni Fontanini

        .LINK
            https://docs.stealthpuppy.com/latestupdate

        .EXAMPLE
            Get-LatestNETFramework -OS "Windows Server 2019"
        
            Description:
            Gets the latest .NET Framework Cumulative update for the given OS.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "Windows OS to search")]
        [ValidateNotNullOrEmpty()]
        [String] $OS
    )

    Process {
        [regex] $rx = "<a[^>]*>([^<]+)<\/a>"

        $kbObj = Get-UpdateCatalogLink -SearchString "Cumulative .NET FrameWork $OS"

        # Find the latest KB ID
        $LastObject = ((($kbObj.Links | Where-Object ID -match '_link').outerHTML -replace $rx, '$1').TrimStart()).TrimEnd() `
            | Sort-Object | Select-Object -last 1
        # Regex the KB from the string
        $kbID = [regex]::match($LastObject,"KB\d*").Groups[0].Value
        
        If ($Null -ne $kbObj) {
            # Contruct a table with KB, Id and Update description
            $idTable = Get-KbUpdateArray -Links $kbObj.Links -KB $kbID

            # Process the IdTable to get a new array with KB, Architecture, Note and URL for each download
            $downloadArray = Get-UpdateDownloadArray -IdTable $idTable

            $downloadArray = $downloadArray | Sort-Object -Property Note | Select-Object -Last 1
        }
        
    }

    End {
        # Write the list of updates to the pipeline
        If ($Null -ne $downloadArray) {
            Write-Output ($downloadArray | Sort-Object -Property Note)
        }
    }
}
