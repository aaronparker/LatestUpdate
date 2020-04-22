Function Set-Proxy {
    <#
        .SYNOPSIS
            Sets proxy config for the session
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    Param (
        [Parameter(Mandatory = $False)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.PSCredential] $ProxyCredential
    )

    Begin {
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    }

    Process {
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
                if ($PSCmdlet.ShouldProcess("Configure proxy server?")) {
                    Write-Verbose "Setting proxy server to $Proxy"
                    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy ($proxyUri, $true)
                }
                
            }
            catch {
                Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
                Throw $_.Exception.Message
            }
        }
    
        If ($ProxyCredential -ne [System.Management.Automation.PSCredential]::Empty) {
            try {
                if ($PSCmdlet.ShouldProcess("Configure proxy credentials?")) {
                    Write-Verbose "Configuring proxy credentials"
                    [System.Net.WebRequest]::DefaultWebProxy.Credentials = $ProxyCredential
                }
            }
            catch {
                Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
                Throw $_.Exception.Message
            }
        }
    }
}