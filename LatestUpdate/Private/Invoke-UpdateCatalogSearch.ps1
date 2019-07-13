Function Invoke-UpdateCatalogSearch {
    <#
        .SYNOPSIS
            Searches the Microsoft Update Catalog for the specific KB number.
    #>
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UpdateId,

        [Parameter(Mandatory = $False)]
        [System.String] $SearchString
    )

    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    If ($Null -ne $resourceStrings) {
        try {
            $iwrParams = @{
                ContentType     = $resourceStrings.ContentType.html
                UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                UseBasicParsing = $True
                ErrorAction     = $resourceStrings.Preferences.ErrorAction
            }
            If ($PSBoundParameters.ContainsKey('SearchString')) {
                $iwrParams.Uri = "$($resourceStrings.CatalogUris.Search)$($UpdateId)+$($SearchString)"
                Write-Verbose -Message "$($MyInvocation.MyCommand): search Catalog for [$UpdateId+$SearchString]"
            }
            Else {
                $iwrParams.Uri = "$($resourceStrings.CatalogUris.Search)$($UpdateId)"
                Write-Verbose -Message "$($MyInvocation.MyCommand): search Catalog for [$UpdateId)]"
            }
            $searchResult = Invoke-WebRequest @iwrParams
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
