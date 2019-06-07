Function Invoke-UpdateCatalogDownloadDialog {
    <#
        .SYNOPSIS
            Searches the Microsoft Update Catalog for the specific update ID to retrieve the notes and download details.
    #>
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Body
    )

    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    If ($Null -ne $resourceStrings) {
        try {
            $params = @{
                Uri             = $resourceStrings.CatalogUris.Download
                Body            = $Body
                ContentType     = $resourceStrings.ContentType.html
                UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                UseBasicParsing = $True
                ErrorAction     = $resourceStrings.Preferences.ErrorAction
            }
            $downloadResult = Invoke-WebRequest @params
        }
        catch [System.Net.WebException] {
            Write-Warning -Message ($($MyInvocation.MyCommand))
            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to search the catalog download: $Uri."
            Throw $_.Exception.Message
        }

        If ($downloadResult.StatusCode -eq "200") {
            Write-Output -InputObject $downloadResult
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): no valid response."
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve Update Catalog download."
    }
}
