Function Invoke-UpdateCatalogDownloadDialog {
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Body
    )

    # Get module strings from the JSON
    $strings = Get-ModuleStrings

    If ($Null -ne $strings) {
        try {
            $params = @{
                Uri             = $strings.CatalogUris.Download
                Body            = $Body
                ContentType     = 'text/html; charset=utf-8'
                UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                UseBasicParsing = $True
                ErrorAction     = "SilentlyContinue"
            }
            $downloadResult = Invoke-WebRequest @params
        }
        catch [System.Net.WebException] {
            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
        }
        catch [System.Exception] {
            Write-Warning -Message "Failed to search the catalog download: $Uri."
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
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retreive Update Catalog download."
    }
}
