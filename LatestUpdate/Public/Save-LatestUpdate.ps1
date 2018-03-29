Function Save-LatestUpdate {
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory=$False, HelpMessage="Download the discovered updates.")]
        [switch]$Download,
    
        [Parameter(Mandatory=$False, HelpMessage="Specify a target path to download the update(s) to.")]
        [ValidateScript({ If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$Path = $PWD
    )    
        ForEach ( $Url in $Urls ) {
            $filename = $Url.Substring($Url.LastIndexOf("/") + 1)
            $target = "$((Get-Item $Path).FullName)\$filename"
            Write-Verbose "`t`tDownload target will be $target"
    
            If (!(Test-Path -Path $target)) {
                If ($pscmdlet.ShouldProcess($Url, "Download")) {
                    # Invoke-WebRequest -Uri $Url -OutFile $target
                    Start-BitsTransfer -Source $Url -Destination $target
                }
            } Else {
                Write-Verbose "File exists: $target. Skipping download."
            }
        }
}