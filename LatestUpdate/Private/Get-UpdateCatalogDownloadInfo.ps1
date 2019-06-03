Function Get-UpdateCatalogDownloadInfo {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UpdateId,

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Architecture = "x64",

        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [System.String] $OS = "Windows 10"
    )

    # Get module strings from the JSON
    $strings = Get-ModuleStrings

    # Search the Update Catalog for the specific update KB
    $searchResult = Invoke-UpdateCatalogIdSearch -UpdateId $UpdateId

    If ($Null -ne $searchResult) {
        # Determine link id's and update description
        $UpdateCatalogItems = ($searchResult.Links | Where-Object { $_.Id -match "_link" })
        ForEach ($UpdateCatalogItem in $UpdateCatalogItems) {
            If (($UpdateCatalogItem.outerHTML -match $strings.Architecture[$Architecture]) -and ($UpdateCatalogItem.outerHTML -match $OS)) {
                $CurrentUpdateDescription = ($UpdateCatalogItem.outerHTML -replace $strings.Matches.DownloadDescription, '$1').TrimStart().TrimEnd()
                $CurrentUpdateLinkID = $UpdateCatalogItem.id.Replace("_link", "")
            }
        }

        # Construct update catalog object that will be used to call update catalog download API
        $UpdateCatalogData = [PSCustomObject] @{
            KB          = $UpdateId
            LinkID      = $CurrentUpdateLinkID
            Description = $CurrentUpdateDescription
        }

        # Construct an ordered hashtable containing the update ID data and convert to JSON
        $UpdateCatalogTable = [ordered] @{
            Size      = 0
            Languages = $strings.Languages.Default
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
        $updateDownloadURL = $updateDownload | Select-Object -ExpandProperty Content | `
            Select-String -AllMatches -Pattern $strings.Matches.DownloadUrl | `
            ForEach-Object { $_.Matches.Value }
            
        $UpdateCatalogDownloadItem = [PSCustomObject] @{
            KB          = $UpdateCatalogData.KB
            Description = $CurrentUpdateDescription
            URL         = $updateDownloadURL
        }
        Write-Output $UpdateCatalogDownloadItem
    }
}
