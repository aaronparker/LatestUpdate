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

        .EXAMPLE

        PS C:\> Get-LatestServicingStackUpdate | Save-LatestUpdate

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Servicing Stack Updates. The output is then passed to Save-LatestUpdate and each update is downloaded locally.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $True, HelpUri = "https://docs.stealthpuppy.com/docs/latestupdate/usage/download")]
    Param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $Updates,

        [Parameter(Mandatory = $False, Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                If (Test-Path -Path $_ -PathType 'Container') {
                    return $true
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
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $ForceWebRequest,

        [Parameter(Mandatory = $False)]
        [ValidateSet('Foreground', 'High', 'Normal', 'Low')]
        [System.String] $Priority = "Foreground",
        
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    # Step through each update in $Updates
    ForEach ($update in $Updates) {

        # Manage updates with multiple URLs
        ForEach ($url in $update.URL) {

            # Create the target file path where the update will be saved
            $updateDownloadTarget = Join-Path -Path $Path -ChildPath (Split-Path -Path $url -Leaf)
                
            # If the update is not already downloaded, download it.
            If ((Test-Path -Path $updateDownloadTarget) -and (-not $Force.IsPresent)) {
                Write-Verbose -Message "File exists: $updateDownloadTarget. Skipping download."
            }
            Else {
                If ($ForceWebRequest -or (Test-PSCore)) {
                    If ($pscmdlet.ShouldProcess($url, "WebDownload")) {
                        #Running on PowerShell Core or ForceWebRequest
                        try {
                            $iwrParams = @{
                                Uri             = $url
                                OutFile         = $updateDownloadTarget
                                UseBasicParsing = $True
                                ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
                            }
                            If ($PSBoundParameters.ContainsKey('Proxy')) {
                                $iwrParams.Proxy = $Proxy
                            }
                            If ($PSBoundParameters.ContainsKey('ProxyCredential')) {
                                $iwrParams.ProxyCredentials = $ProxyCredential
                            }
                            Invoke-WebRequest @iwrParams
                        }
                        catch [System.Net.Http.HttpRequestException] {
                            Write-Warning -Message "$($MyInvocation.MyCommand): HttpRequestException: Check URL is valid: $url."
                            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
                        }
                        catch [System.Net.WebException] {
                            Write-Warning -Message "$($MyInvocation.MyCommand): WebException."
                            Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
                        }
                        catch [System.Exception] {
                            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to download: $url."
                            Throw $_.Exception.Message
                        }
                    }
                }
                Else {
                    If ($pscmdlet.ShouldProcess($(Split-Path -Path $url -Leaf), "BitsDownload")) {
                        #Running on Windows PowerShell
                        try {
                            $sbtParams = @{
                                Source      = $url
                                Destination = $updateDownloadTarget
                                Priority    = $Priority
                                DisplayName = $update.Note
                                Description = "Downloading $url"
                                ErrorAction = $script:resourceStrings.Preferences.ErrorAction
                            }
                            If ($PSBoundParameters.ContainsKey('Proxy')) {
                                # Set priority to Foreground because the proxy will remove the Range protocol header
                                $sbtParams.Priority = "Foreground"
                                $sbtParams.ProxyUsage = "Override"
                                $sbtParams.ProxyList = $Proxy
                            }
                            If ($PSBoundParameters.ContainsKey('ProxyCredential')) {
                                $sbtParams.ProxyCredential = $ProxyCredentials
                            }
                            Start-BitsTransfer @sbtParams
                        }
                        catch [System.Exception] {
                            Write-Warning -Message "$($MyInvocation.MyCommand): Exception: check URL is valid: $url."
                            Throw $_.Exception.Message
                        }
                    }
                }
                If (Test-Path -Path $updateDownloadTarget) {
                    $outputObject = [PSCustomObject] @{
                        KB   = $update.KB
                        Note = $update.Note
                        Path = (Resolve-Path -Path $updateDownloadTarget)
                    }
                    Write-Object -InputObject $outputObject
                }
                Else {
                    Write-Warning -Message "$($MyInvocation.MyCommand): failed to download [$updateDownloadTarget]."
                }
            }
        }
    }
}
