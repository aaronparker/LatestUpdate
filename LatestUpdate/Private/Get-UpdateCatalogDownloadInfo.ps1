Function Get-UpdateCatalogDownloadInfo {
    <#
        .SYNOPSIS
            Builds an object with the update notes and download details.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UpdateId,

        [Parameter(Mandatory = $False)]
        [System.String] $Architecture,

        [Parameter(Mandatory = $False)]
        [Alias('OS')]
        [System.String] $OperatingSystem = "Windows 10|Windows Server",

        [Parameter(Mandatory = $False)]
        [System.String] $SearchString
    )

    # Search the Update Catalog for the specific update KB
    If ($PSBoundParameters.ContainsKey('SearchString')) {
        $searchResult = Invoke-UpdateCatalogSearch -UpdateId $UpdateId -SearchString $SearchString
    }
    Else {
        $searchResult = Invoke-UpdateCatalogSearch -UpdateId $UpdateId
    }

    If ($Null -ne $searchResult) {
        # Output object
        $UpdateCatalogDownloadItems = New-Object -TypeName System.Collections.ArrayList

        # Determine link id's and update description
        $UpdateCatalogItems = ($searchResult.Links | Where-Object { $_.Id -match "_link" })

        ForEach ($UpdateCatalogItem in $UpdateCatalogItems) {
            If (($UpdateCatalogItem.outerHTML -match $Architecture) -and ($UpdateCatalogItem.outerHTML -match $OperatingSystem)) {
                $CurrentUpdateDescription = ($UpdateCatalogItem.outerHTML -replace $script:resourceStrings.Matches.DownloadDescription, '$1').Trim()
                $CurrentUpdateLinkID = $UpdateCatalogItem.id.Replace("_link", "")
                Write-Verbose -Message "$($MyInvocation.MyCommand): match item [$CurrentUpdateDescription]"
            }

            # Construct update catalog object that will be used to call update catalog download API
            $UpdateCatalogData = [PSCustomObject] @{
                KB          = $UpdateId
                LinkID      = $CurrentUpdateLinkID
                Description = $CurrentUpdateDescription
            }

            # Construct an ordered hashtable containing the update ID data and convert to JSON
            $UpdateCatalogTable = [Ordered] @{
                Size      = 0
                Languages = $script:resourceStrings.Languages.Default
                UidInfo   = $UpdateCatalogData.LinkID
                UpdateID  = $UpdateCatalogData.LinkID
            }
            $UpdateCatalogJSON = $UpdateCatalogTable | ConvertTo-Json -Compress

            # Construct body object for web request call
            $Body = @{
                UpdateIDs = "[$($UpdateCatalogJSON)]"
            }

            # Call update catalog download dialog using a rest call
            $updateDownload = Invoke-UpdateCatalogDownloadDialog -Body $Body

            # Match specific update
            If ($Null -ne $updateDownload) {
                $updateDownloadURL = $updateDownload | Select-Object -ExpandProperty Content |
                Select-String -AllMatches -Pattern $script:resourceStrings.Matches.DownloadUrl |
                ForEach-Object { $_.Matches.Value }
                        
                Write-Verbose -Message "$($MyInvocation.MyCommand): extract URL [$updateDownloadURL]"
            
                $UpdateCatalogDownloadItem = [PSCustomObject] @{
                    KB   = $UpdateCatalogData.KB
                    Note = $CurrentUpdateDescription
                    URL  = $updateDownloadURL
                }

                if ($UpdateCatalogDownloadItem.Note) {
                    $UpdateCatalogDownloadItems.Add($UpdateCatalogDownloadItem) | Out-Null
                }
            }
        }

        # Filter unique
        $UpdateCatalogDownloadItems = $UpdateCatalogDownloadItems | Sort-Object -Property Note -Unique
        Write-Output -InputObject $UpdateCatalogDownloadItems
    }
}
