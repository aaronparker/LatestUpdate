Function Set-Proxy {
    <#
        .SYNOPSIS
            Adds a property to a PSObject by querying another property
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.PSCredential] $ProxyCredential
    )

    If ($Proxy) {
        try {
            $proxyUri = new-object System.Uri($Proxy)
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to convert proxy URI to system URI."
            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
            Throw $_.Exception.Message
        }

        try {
            [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy ($proxyUri, $true)
        }
        catch {
            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
            Throw $_.Exception.Message
        }
    }

    If ($ProxyCredential -ne [System.Management.Automation.PSCredential]::Empty) {
        try {
            [System.Net.WebRequest]::DefaultWebProxy.Credentials = $ProxyCredential
        }
        catch {
            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
            Throw $_.Exception.Message
        }
    }
}
