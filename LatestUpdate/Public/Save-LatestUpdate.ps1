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
        [System.Management.Automation.SwitchParameter] $ForceWebRequest,
        
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    # Get module strings from the JSON
    $resourceStrings = Get-ModuleResource

    # Output object
    $updateList = New-Object -TypeName System.Collections.ArrayList

    # Step through each update in $Updates
    ForEach ($update in $Updates) {

        ForEach ($URL in $update.URL) {
            # Create the target file path where the update will be saved
            $filename = Split-Path -Path $URL -Leaf
            $target = Join-Path -Path $Path -ChildPath $filename
                
            # If the update is not already downloaded, download it.
            If ((Test-Path -Path $target) -and (-not $Force.IsPresent)) {
                Write-Verbose -Message "File exists: $target. Skipping download."
            }
            Else {
                If ($ForceWebRequest -or (Test-PSCore)) {
                    If ($pscmdlet.ShouldProcess($URL, "WebDownload")) {
                        #Running on PowerShell Core or ForceWebRequest
                        try {
                            $params = @{
                                Uri             = $URL
                                OutFile         = $target
                                UseBasicParsing = $True
                                ErrorAction     = $resourceStrings.Preferences.ErrorAction
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
                            Write-Warning -Message "$($MyInvocation.MyCommand): failed to download: $URL."
                            Throw $_.Exception.Message
                        }
                    }
                }
                Else {
                    If ($pscmdlet.ShouldProcess($(Split-Path $URL -Leaf), "BitsDownload")) {
                        #Running on Windows PowerShell
                        try {
                            $params = @{
                                Source      = $URL
                                Destination = $target 
                                Priority    = "High"
                                DisplayName = "test"
                                Description = "Downloading $URL"
                                ErrorAction = $resourceStrings.Preferences.ErrorAction
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
                            Write-Warning -Message "$($MyInvocation.MyCommand): failed to download: $URL."
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
    }

    # Output results to the pipeline
    Write-Output -InputObject $updateList
}
