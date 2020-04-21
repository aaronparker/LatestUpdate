Function Save-LatestUpdate {
    <#
        .SYNOPSIS
            Downloads the updates passed from other LatestUpdate Get functions.

        .DESCRIPTION
            Downloads the updates passed from other LatestUpdate Get functions to a local folder.
            
            Use functions such as Get-LatestCumulativeUpdate and Get-LatestMonthlyRollup to retrieve the list of updates to then pass to Save-LatestUpdate to download each update locally. 

            Do one or more of the following with the downloaded updates:
            - Import the update into an MDT share to speed deployment of Windows (new PCs, reference images etc.)
            - Apply the update to an offline WIM using DISM
            - Deploy the update with ConfigMgr (if not using WSUS)

        .PARAMETER Updates
            Specifies the list of updates from other LatestUpdate functions such as Get-LatestCumulativeUpdate and Get-LatestMonthlyRollup.

        .PARAMETER Path
            Specifies a path as the destination for the downloaded updates. All updates passed in -Updates will be downloaded to this path.

        .PARAMETER ForceWebRequest
            Forces the use of Invoke-WebRequest instead of Start-BitsTransfer when running under Windows PowerShell.

        .PARAMETER Priority
            Specifies the priority of a BITS transfer job. Defaults to Foreground. Foreground will enforced when proxy credentials are passed to Save-LatestUpdate

        .PARAMETER Proxy
            Specifies a proxy server address to use when initiating a download.

        .PARAMETER ProxyCredential
            Specifies a [System.Management.Automation.PSCredential] object to use when the proxy server requires authentication.

        .PARAMETER Force
            Specifies that existing downloaded updates will be re-downloaded and overwritten.

        .EXAMPLE

        PS C:\> $Updates = Get-LatestCumulativeUpdate
        PS C:\> Save-LatestUpdate -Updates $Updates -Path C:\Temp\Updates

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Cumulative Updates. Save-LatestUpdate will download each returned update to C:\Temp\Updates.

        .EXAMPLE

        PS C:\> Get-LatestServicingStackUpdate | Save-LatestUpdate

        This commands reads the the Windows 10 update history feed and returns an object that lists the most recent Windows 10 Servicing Stack Updates. The output is then passed to Save-LatestUpdate and each update is downloaded to the current directory.
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
                    Return $true
                }
                Else {
                    Throw "Cannot find path $_"
                }
            })]
        [System.String] $Path = $PWD,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $ForceWebRequest,

        [Parameter(Mandatory = $False)]
        [ValidateSet('BitsTransfer', 'WebRequest', 'WebClient')]
        [System.String] $Method = 'BitsTransfer',

        [Parameter(Mandatory = $False)]
        [ValidateSet('Foreground', 'High', 'Normal', 'Low')]
        [System.String] $Priority = "Foreground",

        [Parameter(Mandatory = $False)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $False)]
        [ValidateSet('Basic', 'Digest', 'Ntlm', 'Negotiate', 'Passport')]
        [System.String] $ProxyAuthentication = 'Negotiate',
        
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    Begin {
        if ($PSBoundParameters.ContainsKey('Proxy') -or $PSBoundParameters.ContainsKey('ProxyCredential')) {
            $null = Set-Proxy -Proxy $Proxy -ProxyCredential $ProxyCredential
        }

        # Disable the Invoke-WebRequest progress bar for faster downloads
        If ($PSBoundParameters.ContainsKey('Verbose')) {
            $ProgressPreference = "Continue"
        }
        Else {
            $ProgressPreference = "SilentlyContinue"
        }
    }    

    Process {
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
                        #Running on PowerShell Core or ForceWebRequest
                        $Method = 'WebRequest'
                    }

                    Switch ($Method) {
                        'BitsTransfer' {
                            #Running on Windows PowerShell
                            If ($pscmdlet.ShouldProcess($(Split-Path -Path $url -Leaf), "BitsDownload")) {
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
                                        $sbtParams.ProxyAuthentication = $ProxyAuthentication
                                        $sbtParams.ProxyCredential = $ProxyCredential
                                    }
                                    Start-BitsTransfer @sbtParams
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Exception: check URL is valid: $url."
                                    Throw $_.Exception.Message
                                }
                            }
                        }
                        'WebRequest' {
                            #Running on PowerShell Core or ForceWebRequest
                            If ($ForceWebRequest -or (Test-PSCore) -or ($pscmdlet.ShouldProcess($url, "WebDownload"))) {
                                try {
                                    $iwrParams = @{
                                        Uri             = $url
                                        OutFile         = $updateDownloadTarget
                                        UseBasicParsing = $True
                                        ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
                                    }
                                    Invoke-WebRequest @iwrParams
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
                        'WebClient' {
                            If ($pscmdlet.ShouldProcess($(Split-Path -Path $url -Leaf), "WebClient")) {
                                try {
                                    $webClient = New-Object -TypeName System.Net.WebClient
                                    $webClient.DownloadFile($url, $updateDownloadTarget)
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
                    }

                    If (Test-Path -Path $updateDownloadTarget) {
                        $outputObject = [PSCustomObject] @{
                            KB   = $update.KB
                            Note = $update.Note
                            Path = (Resolve-Path -Path $updateDownloadTarget)
                        }
                        Write-Output -InputObject $outputObject
                    }
                    Else {
                        Write-Warning -Message "$($MyInvocation.MyCommand): failed to download [$updateDownloadTarget]."
                    }
                }
            }
        }
    }
}
