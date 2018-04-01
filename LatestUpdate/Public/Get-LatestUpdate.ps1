Function Get-LatestUpdate {
    <#
    .SYNOPSIS
        Get the latest Cumulative update for Windows

    .DESCRIPTION
        This script will return the list of Cumulative updates for Windows 10 and Windows Server 2016 from the Microsoft Update Catalog. Optionally download the updates using the -Download parameter.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

        Original script: Copyright Keith Garner, All rights reserved.
        Forked from: https://gist.github.com/keithga/1ad0abd1f7ba6e2f8aff63d94ab03048

    .LINK
        https://support.microsoft.com/en-us/help/4043454

    .PARAMETER Build
        Specify the Windows build number for searching cumulative updates. Supports '16299', '15063', '14393', '10586', '10240'.

    .PARAMETER SearchString
        Specify a specific search string to change the target update behaviour. The default will only download Cumulative updates for x64.

    .EXAMPLE
        Get-LatestUpdate

        Description:
        Get the latest Cumulative Update for Windows 10 x64

    .EXAMPLE
        Get-LatestUpdate -SearchString 'Cumulative.*x86'

        Description:
        Enumerate the latest Cumulative Update for Windows 10 x86 (Semi-Annual Channel)

    .EXAMPLE
        Get-LatestUpdate -SearchString 'Cumulative.*Server.*x64' -Build 14393    
    
        Description:
        Enumerate the latest Cumulative Update for Windows Server 2016
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $False, HelpMessage = "JSON source for the update KB articles.")]
        [Parameter(ParameterSetName = 'Download', Mandatory = $False)]
        [string]$StartKB = 'https://support.microsoft.com/app/content/api/content/asset/en-us/4000816',

        [Parameter(Mandatory = $False, HelpMessage = "Windows build number.")]
        [ValidateSet('16299', '15063', '14393', '10586', '10240')]
        [string]$Build = '16299',

        [Parameter(Mandatory = $False, HelpMessage = "Search query string.")]
        [string]$SearchString = 'Cumulative.*x64'
    )
    Begin {
    }
    Process {
        #region Find the KB Article Number
        Write-Verbose "Downloading $StartKB to retrieve the list of updates."
        $kbID = (Invoke-WebRequest -Uri $StartKB).Content |
            ConvertFrom-Json |
            Select-Object -ExpandProperty Links |
            Where-Object level -eq 2 |
            Where-Object text -match $Build |
            Select-LatestUpdate |
            Select-Object -First 1
        #endregion

        #region get the download link from Windows Update
        $Kb = $kbID.articleID
        Write-Verbose "Found ID: KB$($kbID.articleID)"
        $kbObj = Invoke-WebRequest -Uri "http://www.catalog.update.microsoft.com/Search.aspx?q=KB$($kbID.articleID)"

        # Parse the available KB IDs
        $Available_kbIDs = $kbObj.InputFields | 
            Where-Object { $_.Type -eq 'Button' -and $_.Value -eq 'Download' } | 
            Select-Object -ExpandProperty ID
        Write-Verbose "Ids found:"
        ForEach ($id in $Available_kbIDs) {
            "`t$($id | Out-String)" | Write-Verbose
        }

        # Invoke-WebRequest on PowerShell Core doesn't return innerText
        # (Same as Invoke-WebRequest -UseBasicParsing on Windows PS)
        If (Test-PSCore) {
            Write-Verbose "Using outerHTML. Parsing KB notes"
            $kbIDs = $kbObj.Links | 
                Where-Object ID -match '_link' |
                Where-Object outerHTML -match $SearchString |
                ForEach-Object { $_.Id.Replace('_link', '') } |
                Where-Object { $_ -in $Available_kbIDs }
        }
        Else {
            Write-Verbose "innerText found. Parsing KB notes"
            $kbIDs = $kbObj.Links | 
                Where-Object ID -match '_link' |
                Where-Object innerText -match $SearchString |
                ForEach-Object { $_.Id.Replace('_link', '') } |
                Where-Object { $_ -in $Available_kbIDs }
        }

        $Urls = @()
        ForEach ( $kbID in $kbIDs ) {
            Write-Verbose "Download $kbID"
            $Post = @{ size = 0; updateID = $kbID; uidInfo = $kbID } | ConvertTo-Json -Compress
            $PostBody = @{ updateIDs = "[$Post]" } 
            $Urls += Invoke-WebRequest -Uri 'http://www.catalog.update.microsoft.com/DownloadDialog.aspx' -Method Post -Body $postBody |
                Select-Object -ExpandProperty Content |
                Select-String -AllMatches -Pattern "(http[s]?\://download\.windowsupdate\.com\/[^\'\""]*)" | 
                ForEach-Object { $_.matches.value }
        }
        #endregion

        # Select the update names
        If (Test-PSCore) {
            # Updated for PowerShell Core
            $Notes = ([regex]'(?<note>\d{4}-\d{2}.*\(KB\d{7}\))').match($kbObj.RawContent).Value
        }
        Else {
            # Original code for Windows PowerShell
            $Notes = $kbObj.ParsedHtml.body.getElementsByTagName('a') | ForEach-Object InnerText | Where-Object { $_ -match $SearchString }
        }

        [int]$i = 0; $Output = @()
        ForEach ( $Url in $Urls ) {
            $item = New-Object PSObject
            $item | Add-Member -type NoteProperty -Name 'KB' -Value "KB$Kb"
            If ( $Notes.Count -eq 1 ) {
                $item | Add-Member -type NoteProperty -Name 'Note' -Value $Notes
            }
            Else {
                $item | Add-Member -type NoteProperty -Name 'Note' -Value $Notes[$i]
            }
            $item | Add-Member -type NoteProperty -Name 'URL' -Value $Url
            $Output += $item
            $i = $i + 1
        }
    }
    End {
        # Write the URLs list to the pipeline
        Write-Output $Output
    }
}