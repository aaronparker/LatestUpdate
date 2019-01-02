Function Get-LatestUpdate {
    <#
    .SYNOPSIS
        Get the latest Cumulative or Monthly Rollup update for Windows.

    .DESCRIPTION
        Returns the latest Cumulative or Monthly Rollup updates for Windows 10 / 8.1 / 7 and corresponding Windows Server from the Microsoft Update Catalog by querying the Update History page.

        Get-LatestUpdate outputs the result as a table that can be passed to Save-LatestUpdate to download the update locally. Then do one or more of the following:
        - Import the update into an MDT share with Import-LatestUpdate to speed up deployment of Windows (reference images etc.)
        - Apply the update to an offline WIM using DISM
        - Deploy the update with ConfigMgr (if not using WSUS)

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

        Original script: Copyright Keith Garner, All rights reserved.
        Forked from: https://gist.github.com/keithga/1ad0abd1f7ba6e2f8aff63d94ab03048

    .LINK
        https://support.microsoft.com/en-au/help/4464619

    .PARAMETER WindowsVersion
        Specifiy the Windows version to search for updates. Valid values are Windows10, Windows8, Windows7 (applies to desktop and server editions).

    .PARAMETER Build
        Dynamic parameter used with -WindowsVersion 'Windows10' Specify the Windows 10 build number for searching cumulative updates. Supports '17133', '16299', '15063', '14393', '10586', '10240'.

    .EXAMPLE
        Get-LatestUpdate

        Description:
        Get the latest Cumulative Update for Windows 10 Semi-Annual Channel.

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows10

        Description:
        Get the latest Cumulative Update for Windows 10 Semi-Annual Channel.

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows10 -Build 14393
    
        Description:
        Enumerate the latest Cumulative Update for Windows 10 1607 and Windows Server 2016.

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows10 -Build 15063
    
        Description:
        Enumerate the latest Cumulative Update for Windows 10 1703.

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows8
    
        Description:
        Enumerate the latest Monthly Update for Windows Server 2012 R2 / Windows 8.1.

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows7
    
        Description:
        Enumerate the latest Monthly Update for Windows 7 (and Windows 7 Embedded).
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $False, Position = 0, HelpMessage = "Select the OS to search for updates")]
        [ValidateSet('Windows10', 'Windows8', 'Windows7')]
        [String] $WindowsVersion = "Windows10",

        [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Provide a Windows 10 build number")]
        [ValidateSet('17763', '17134', '16299', '15063', '14393', '10586', '10240', '^(?!.*Preview)(?=.*Monthly).*')]
        [String] $Build = "17763"
    )
    Begin {
        # Set values for -Build and -SearchString as required for each platform
        Switch ($WindowsVersion) {
            "Windows10" {
                [String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/6ae59d69-36fc-8e4d-23dd-631d98bf74a9/atom'
                If ($Build -eq "^(?!.*Preview)(?=.*Monthly).*") { $Build = "17763" }
            }
            "Windows8" {
                [String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/b905caa1-d413-c90c-bed3-20aead901092/atom'
                [String] $Build = "^(?!.*Preview)(?=.*Monthly).*"
            }
            "Windows7" {
                [String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/f825ca23-c7d1-aab8-4513-64980e1c3007/atom'
                [String] $Build = "^(?!.*Preview)(?=.*Monthly).*"
            }
        }
        Write-Verbose -Message "Checking updates for $WindowsVersion $Build."
    }
    Process {
        #region Find the KB Article Number
        #! Fix for Invoke-WebRequest creating BOM in XML files; Handle Temp locations on Windows, macOS / Linux
        try {
            If (Test-Path env:Temp) {
                $tempDir = $env:Temp
            }
            ElseIf (Test-Path env:TMPDIR) {
                $tempDir = $env:TMPDIR
            }
            $tempFile = Join-Path -Path $tempDir -ChildPath ([System.IO.Path]::GetRandomFileName())
            Write-Verbose -Message "Downloading $StartKB to retrieve the list of updates."
            Invoke-WebRequest -Uri $StartKB -ContentType 'application/atom+xml; charset=utf-8' `
                -UseBasicParsing -OutFile $tempFile -ErrorAction SilentlyContinue
            Write-Verbose -Message "Read RSS feed into $tempFile."
        }
        catch {
            Throw $_
            Break
        }
        
        # Import the XML from the feed into a variable and delete the temp file
        try {
            $xml = [xml] (Get-Content -Path $tempFile -ErrorAction SilentlyContinue)
        }
        catch {
            Write-Error "Failed to read XML from $tempFile."
            Break
        }
        try {
            Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
        }
        catch {
            Write-Warning -Message "Failed to remove file $tempFile."
        }
        #! End fix
        
        try {
            Switch ( $WindowsVersion ) {
                "Windows10" { 
                    # Sort feed for titles that match Build number; Find the largest minor build number
                    [regex] $rx = "$Build.(\d+)"
                    $buildMatches = $xml.feed.entry | Where-Object -Property title -match $Build
                    Write-Verbose -Message "Found $($buildMatches.Count) items matching build $Build."
                    $LatestVersion = $buildMatches | ForEach-Object { ($rx.match($_.title)).value.split('.') | Select-Object -Last 1} `
                        | ForEach-Object { [convert]::ToInt32($_, 10) } | Sort-Object -Descending | Select-Object -First 1

                    # Re-match feed for major.minor number and return the KB number from the Id field
                    Write-Verbose -Message "Latest Windows 10 build is: $Build.$LatestVersion."
                    $kbID = $xml.feed.entry | Where-Object -Property title -match "$Build.$LatestVersion" | Select-Object -ExpandProperty id `
                        | ForEach-Object { $_.split(':') | Select-Object -Last 1 }
                }
                default {
                    $buildMatches = $xml.feed.entry | Where-Object -Property title -match $Build
                    $kbID = $buildMatches | Select-Object -ExpandProperty ID | ForEach-Object { $_.split(':') | Select-Object -Last 1 } `
                        | Sort-Object -Descending | Select-Object -First 1   
                }
            }
        }
        catch {   
            If ($Null -eq $kbID) { Write-Warning -Message "kbID is Null. Unable to read from the KB from the JSON." }
            Break
        }
        #endregion

        #region get the download link from Windows Update
        try {
            Write-Verbose -Message "Found ID: KB$($kbID)"
            Write-Verbose -Message "Reading http://www.catalog.update.microsoft.com/Search.aspx?q=KB$($kbID)."
            $kbObj = Invoke-WebRequest -Uri "http://www.catalog.update.microsoft.com/Search.aspx?q=KB$($kbID)" `
                -UseBasicParsing -ErrorAction SilentlyContinue
        }
        catch {
            # Write warnings if we can't read values
            If ($Null -eq $kbObj) { Write-Warning -Message "kbObj is Null. Unable to read KB details from the Catalog." }
            If ($Null -eq $kbObj.InputFields) { Write-Warning -Message "kbObj.InputFields is Null. Unable to read button details from the Catalog KB page." }
            Throw $_
            Break
        }
        #endregion

        # Contruct a table with KB, Id and Update description
        Write-Verbose -Message "Contructing temporary table with KB, ID and URL."
        [regex] $rx = "<a[^>]*>([^<]+)<\/a>"
        $idTable = $kbObj.Links | Where-Object ID -match '_link' | `
            Select-Object @{n = "KB"; e = {"KB$kbID"}}, @{n = "Id"; e = {$_.id.Replace('_link', '')}}, `
        @{n = "Note"; e = {(($_.outerHTML -replace $rx, '$1').TrimStart()).TrimEnd()}}

        $output = @()
        ForEach ($idItem in $idTable) {
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
                [regex] $rx = "\s+([a-zA-Z0-9]+)-based"
                $idItem.Note -match $rx > $Null
                $newItem | Add-Member -type NoteProperty -Name 'Arch' -Value $Matches[1]
                $newItem | Add-Member -type NoteProperty -Name 'Note' -Value $idItem.Note
                $newItem | Add-Member -type NoteProperty -Name 'URL' -Value $url
                $output += $newItem
            }
        }
        #endregion
    }
    End {
        # Write the URLs list to the pipeline
        Write-Output $output
    }
}
