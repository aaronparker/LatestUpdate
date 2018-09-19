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
        https://support.microsoft.com/en-us/help/4043454

    .PARAMETER WindowsVersion
        Specifiy the Windows version to search for updates. Valid values are Windows10, Windows8, Windows7 (applies to desktop and server editions).

    .PARAMETER Build
        Dynamic parameter used with -WindowsVersion 'Windows10' Specify the Windows 10 build number for searching cumulative updates. Supports '17133', '16299', '15063', '14393', '10586', '10240'.

    .PARAMETER SearchString
        Dynamic parameter. Specify a specific search string to change the target update behaviour. The default will only download Cumulative updates for x64.

    .EXAMPLE
        Get-LatestUpdate

        Description:
        Get the latest Cumulative Update for Windows 10 x64 (Semi-Annual Channel)

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows10 -Architecture x86

        Description:
        Enumerate the latest Cumulative Update for Windows 10 x86 (Semi-Annual Channel)

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows10 -Build 14393
    
        Description:
        Enumerate the latest Cumulative Update for Windows 10 1607 and Windows Server 2016

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows10 -Build 15063 -Architecture x86
    
        Description:
        Enumerate the latest Cumulative Update for Windows 10 x86 1703

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows8
    
        Description:
        Enumerate the latest Monthly Update for Windows Server 2012 R2 / Windows 8.1 x64

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows8 -Architecture x86
    
        Description:
        Enumerate the latest Monthly Update for Windows 8.1 x86

    .EXAMPLE
        Get-LatestUpdate -WindowsVersion Windows7 -Architecture x86
    
        Description:
        Enumerate the latest Monthly Update for Windows 7 (and Windows 7 Embedded) x86
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $False, Position = 0, HelpMessage = "Select the OS to search for updates")]
        [ValidateSet('Windows10', 'Windows8', 'Windows7')]
        [String] $WindowsVersion = "Windows10"
    )
    DynamicParam {
        # Create dynamic parameters. Windows 10 can use -Build and -Architecture
        # Windows 8/7 use -Architecture only
        $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        If ( $WindowsVersion -eq "Windows10") {
            $args = @{
                Name         = "Build"
                Type         = [String]
                ValidateSet  = @('17134', '16299', '15063', '14393', '10586', '10240')
                Position     = 1
                HelpMessage  = "Provide a Windows 10 build number"
                DPDictionary = $Dictionary
            }
            New-DynamicParam @args
            $args = @{
                Name         = "Architecture"
                Type         = [String]
                ValidateSet  = @('x64', 'x86')
                Position     = 2
                HelpMessage  = "Processor architecture to return updates for."
                DPDictionary = $Dictionary
            }
            New-DynamicParam @args
        }
        If ( ($WindowsVersion -eq "Windows8") -or ($WindowsVersion -eq "Windows7") ) {
            $args = @{
                Name         = "Architecture"
                Type         = [String]
                ValidateSet  = @('x64', 'x86')
                Position     = 1
                HelpMessage  = "Processor architecture to return updates for."
                DPDictionary = $Dictionary
            }
            New-DynamicParam @args
        }
        #return RuntimeDefinedParameterDictionary
        Write-Output $Dictionary
    }
    Begin {
        # Get the dynamic parameters and assign to parameters
        Function _temp { [cmdletbinding()] param() }
        $BoundKeys = $PSBoundParameters.keys | Where-Object { (Get-Command _temp | Select-Object -ExpandProperty parameters).Keys -notcontains $_}
        ForEach ($param in $BoundKeys) {
            If (-not ( Get-Variable -name $param -scope 0 -ErrorAction SilentlyContinue ) ) {
                New-Variable -Name $Param -Value $PSBoundParameters.$param
                Write-Verbose "Adding variable for dynamic parameter '$param' with value '$($PSBoundParameters.$param)'"
            }
        }
        # Set values for -Build and -SearchString as required for each platform
        Switch ( $WindowsVersion ) {
            "Windows10" {
                [String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/6ae59d69-36fc-8e4d-23dd-631d98bf74a9/atom'
                If ( $Null -eq $Build ) { [String] $Build = "17134" }
                [String] $SearchString = Switch ( $Architecture ) {
                    "x64" { 'Cumulative.*x64' }
                    "x86" { 'Cumulative.*x86' }
                    Default { 'Cumulative.*x64' }
                }
            }
            "Windows8" {
                [String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/b905caa1-d413-c90c-bed3-20aead901092/atom'
                [String] $Build = "^(?!.*Preview)(?=.*Monthly).*"
                [String] $SearchString = Switch ( $Architecture ) {
                    "x64" { ".*x64" }
                    "x86" { ".*x86" }
                    Default { ".*x64" }
                }
            }
            "Windows7" {
                [String] $StartKB = 'https://support.microsoft.com/app/content/api/content/feeds/sap/en-us/f825ca23-c7d1-aab8-4513-64980e1c3007/atom'
                [String] $Build = "^(?!.*Preview)(?=.*Monthly).*"
                [String] $SearchString = Switch ( $Architecture ) {
                    "x64" { ".*x64" }
                    "x86" { ".*x86" }
                    Default { ".*x64" }
                }
            }
        }
        Write-Verbose "Check updates for $Build $SearchString"
    }
    Process {
        #region Find the KB Article Number
        Write-Verbose "Downloading $StartKB to retrieve the list of updates."
        #! fix for invoke-webrequests creating BOM in XML files
        $tempfile = Join-Path -Path $env:temp -ChildPath ([System.IO.Path]::GetRandomFileName())
        Invoke-WebRequest -uri $StartKB -ContentType 'application/atom+xml; charset=utf-8' -OutFile $tempfile
        $XML = [xml](Get-Content -Path $tempfile)
        Remove-Item -Path $tempfile
        #! end fix
        $ID = $xml.feed.entry | Where-Object -Property title -match $build |  Sort-Object -Property ID -Descending | select -first 1 | Select-Object -ExpandProperty ID
        $kbID = $ID.split(':') | select -last 1

        If ( $Null -eq $kbID ) { Write-Warning -Message "kbID is Null. Unable to read from the KB from the JSON." }
        #endregion

        #region get the download link from Windows Update
        $kb = $kbID
        Write-Verbose "Found ID: KB$($kbID)"
        $kbObj = Invoke-WebRequest -Uri "http://www.catalog.update.microsoft.com/Search.aspx?q=KB$($kbID)"

        # Write warnings if we can't read values
        If ( $Null -eq $kbObj ) { Write-Warning -Message "kbObj is Null. Unable to read KB details from the Catalog." }
        If ( $Null -eq $kbObj.InputFields ) { Write-Warning -Message "kbObj.InputFields is Null. Unable to read button details from the Catalog KB page." }
        #endregion

        #region Parse the available KB IDs
        $availableKbIDs = $kbObj.InputFields | 
            Where-Object { $_.Type -eq 'Button' -and $_.Value -eq 'Download' } | 
            Select-Object -ExpandProperty ID
        Write-Verbose "Ids found:"
        ForEach ( $id in $availableKbIDs ) {
            "`t$($id | Out-String)" | Write-Verbose
        }
        #endregion

        #region Invoke-WebRequest on PowerShell Core doesn't return innerText
        # (Same as Invoke-WebRequest -UseBasicParsing on Windows PS)
        If ( Test-PSCore ) {
            Write-Verbose "Using outerHTML. Parsing KB notes"
            $kbIDs = $kbObj.Links | 
                Where-Object ID -match '_link' |
                Where-Object outerHTML -match $SearchString |
                ForEach-Object { $_.Id.Replace('_link', '') } |
                Where-Object { $_ -in $availableKbIDs }
        }
        Else {
            Write-Verbose "innerText found. Parsing KB notes"
            $kbIDs = $kbObj.Links | 
                Where-Object ID -match '_link' |
                Where-Object innerText -match $SearchString |
                ForEach-Object { $_.Id.Replace('_link', '') } |
                Where-Object { $_ -in $availableKbIDs }
        }
        #endregion

        #region Read KB details
        $urls = @()
        ForEach ( $kbID in $kbIDs ) {
            Write-Verbose "Download $kbID"
            $post = @{ size = 0; updateID = $kbID; uidInfo = $kbID } | ConvertTo-Json -Compress
            $postBody = @{ updateIDs = "[$post]" } 
            $urls += Invoke-WebRequest -Uri 'http://www.catalog.update.microsoft.com/DownloadDialog.aspx' -Method Post -Body $postBody |
                Select-Object -ExpandProperty Content |
                Select-String -AllMatches -Pattern "(http[s]?\://download\.windowsupdate\.com\/[^\'\""]*)" | 
                ForEach-Object { $_.matches.value }
        }
        #endregion

        #region Select the update names
        If ( Test-PSCore ) {
            # Updated for PowerShell Core
            $notes = ([regex]'(?<note>\d{4}-\d{2}.*\(KB\d{7}\))').match($kbObj.RawContent).Value
        }
        Else {
            # Original code for Windows PowerShell
            $notes = $kbObj.ParsedHtml.body.getElementsByTagName('a') | ForEach-Object InnerText | Where-Object { $_ -match $SearchString }
        }
        #endregion

        #region Build the output array
        [int] $i = 0; $output = @()
        ForEach ( $url in $urls ) {
            $item = New-Object PSObject
            $item | Add-Member -type NoteProperty -Name 'KB' -Value "KB$Kb"
            If ( $notes.Count -eq 1 ) {
                $item | Add-Member -type NoteProperty -Name 'Note' -Value $notes
            }
            Else {
                $item | Add-Member -type NoteProperty -Name 'Note' -Value $notes[$i]
            }
            $item | Add-Member -type NoteProperty -Name 'URL' -Value $url
            $output += $item
            $i = $i + 1
        }
        #endregion
    }
    End {
        # Write the URLs list to the pipeline
        Write-Output $output
    }
}
