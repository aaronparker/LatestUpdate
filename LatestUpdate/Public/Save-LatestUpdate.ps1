Function Save-LatestUpdate {
    <#
        .SYNOPSIS
            Downloads the latest Windows 10 Cumulative, Servicing Stack and Adobe Flash Player updates.

        .DESCRIPTION
            Downloads the latest Windows 10 Cumulative, Servicing Stack and Adobe Flash Player updates to a local folder.

            Then do one or more of the following:
            - Import the update into an MDT share with Import-LatestUpdate to speed up deployment of Windows (reference images etc.)
            - Apply the update to an offline WIM using DISM
            - Deploy the update with ConfigMgr (if not using WSUS)
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $True, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/download")]
    Param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $Update,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                If (Test-Path -Path $_ -PathType 'Container') {
                    Return $True
                }
                Else {
                    Throw "Cannot find path $_"
                }
            })]
        [System.String] $Path = $PWD,

        [Parameter(Mandatory = $False)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.PSCredential]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $False)]
        [System.Switch] $ForceWebRequest
    )

    # Get module strings from the JSON
    $strings = Get-ModuleString

    # Output object
    $updateList = New-Object -TypeName System.Collections.ArrayList

    # Step through each update in $Updates
    ForEach ($update in $Updates) {

        # Create the target file path where the update will be saved
        $filename = Split-Path -Path $update.URL -Leaf
        $target = Join-Path -Path $Path -ChildPath $filename
            
        # If the update is not already downloaded, download it.
        If (Test-Path -Path $target) {
            Write-Verbose -Message "File exists: $target. Skipping download."
        }
        Else {
            If ($ForceWebRequest -or (Test-PSCore)) {
                If ($pscmdlet.ShouldProcess($update.URL, "WebDownload")) {
                    #Running on PowerShell Core or ForceWebRequest
                    try {
                        $params = @{
                            Uri             = $update.URL
                            OutFile         = $target
                            UseBasicParsing = $True
                            ErrorAction     = $strings.Preferences.ErrorAction
                        }
                        If ($PSBoundParameters.ContainsKey($Proxy)) {
                            $params.Proxy = $Proxy
                        }
                        If ($PSBoundParameters.ContainsKey($Credential)) {
                            $params.ProxyCredentials = $Credential
                        }
                        $result = Invoke-WebRequest @params
                    }
                    catch [System.Net.WebException] {
                        Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): failed to download: $($update.URL)."
                        Throw $_.Exception.Message
                    }
                }
            }
            Else {
                If ($pscmdlet.ShouldProcess($(Split-Path $update.URL -Leaf), "BitsDownload")) {
                    #Running on Windows PowerShell
                    try {
                        $params = @{
                            Source      = $update.URL
                            Destination = $target 
                            Priority    = "High"
                            DisplayName = $update.Note
                            Description = "Downloading $($update.URL)"
                            ErrorAction = $strings.Preferences.ErrorAction
                        }
                        If ($PSBoundParameters.ContainsKey($Proxy)) {
                            # Set priority to Foreground because the proxy will remove the Range protocol header
                            $params.Priority = "Foreground"
                            $params.ProxyUsage = "Override"
                            $params.ProxyList = $Proxy
                        }
                        If ($PSBoundParameters.ContainsKey($Credential)) {
                            $params.ProxyCredential = $ProxyCredentials
                        }
                        $result = Start-BitsTransfer @params
                    }
                    catch [System.Net.WebException] {
                        Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): failed to download: $($update.URL)."
                        Throw $_.Exception.Message
                    }
                }
            }
            If ($result.StatusCode -eq "200") {
                $PSObject = [PSCustomObject] @{
                    Note   = $update.Note
                    ID     = $update.KB
                    Target = $target
                }
                $updateList.Add($PSObject) | Out-Null
            }
            Else {
                Write-Warning -Message "$($MyInvocation.MyCommand): no valid response."
            }
        }
    }

    # Output results to the pipeline
    Write-Output -InputObject $updateList
}
