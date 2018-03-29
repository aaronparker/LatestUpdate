Function Save-LatestUpdate {
    <#
    .SYNOPSIS
        Downloads the latest cumulative update passed from Get-LatestUpdate.

    .DESCRIPTION
        Downloads the latest cumulative update passed from Get-LatestUpdate to a local folder. The update can then be imported into an MDT share with Import-LatestUpdate.

    .NOTES

    .PARAMETER Updates
        The array of latest cumulative updates retreived by Get-LatestUpdate.

    .PARAMETER Path
        A destination path for downloading the cumulative updates to.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Array])]
    Param(
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "The array of updates from Get-LatestUpdate.")]
        [ValidateNotNullOrEmpty()]
        [array]$Updates,
    
        [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Specify a target path to download the update(s) to.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$Path = $PWD
    )
    Begin {
        $Urls = $Updates | Select-UniqueUrl
    } 
    Process {
        ForEach ( $Url in $Urls ) {
            # $Filename = $Url.Substring($Url.LastIndexOf("/") + 1)
            $Filename = Split-Path $Url -Leaf
            $Target = "$((Get-Item $Path).FullName)\$Filename"
            Write-Verbose "`t`tDownload target will be $Target"
    
            If (!(Test-Path -Path $Target)) {
                If (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
                    If ($pscmdlet.ShouldProcess($Url, "BitsDownload")) {
                        Start-BitsTransfer -Source $Url -Destination $Target `
                            -Priority High -ErrorAction Continue -ErrorVariable $ErrorBits `
                            -DisplayName "Windows 10 Cumulative Update" -Description "Downloading the latest Windows 10 Cumulative update"
                    }
                }
                Else {
                    If ($pscmdlet.ShouldProcess($Url, "WebDownload")) {
                        Invoke-WebRequest -Uri $Url -OutFile $Target
                    }
                }
            }
            Else {
                Write-Verbose "File exists: $target. Skipping download."
            }
        }
    }
    End {
        $Urls
    }
}