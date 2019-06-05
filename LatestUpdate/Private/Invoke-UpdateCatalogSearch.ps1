Function Invoke-UpdateCatalogSearch {
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UpdateId
    )

    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    If ($Null -ne $resourceStrings) {
        try {
            $params = @{
                Uri             = "$($resourceStrings.CatalogUris.Search)$($UpdateId)"
                ContentType     = $resourceStrings.ContentType.html
                UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                UseBasicParsing = $True
                ErrorAction     = $resourceStrings.Preferences.ErrorAction
            }
            Write-Verbose -Message "$($MyInvocation.MyCommand): search Catalog for [$UpdateId)]"
            $searchResult = Invoke-WebRequest @params
        }
        catch [System.Net.WebException] {
            Write-Warning -Message ($($MyInvocation.MyCommand))
            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to search the catalog: $Uri."
            Throw $_.Exception.Message
        }

        If ($searchResult.StatusCode -eq "200") {
            Write-Output -InputObject $searchResult
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): no valid response."
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retreive Update Catalog search URI."
    }
}
