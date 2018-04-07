Function Save-LatestUpdate {
    <#
    .SYNOPSIS
        Downloads the latest cumulative update passed from Get-LatestUpdate.

    .DESCRIPTION
        Downloads the latest cumulative update passed from Get-LatestUpdate to a local folder.

        Then do one or more of the following:
        - Import the update into an MDT share with Import-LatestUpdate to speed up deployment of Windows (reference images etc.)
        - Apply the update to an offline WIM using DISM
        - Deploy the update with ConfigMgr (if not using WSUS)

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .PARAMETER Updates
        The array of latest cumulative updates retreived by Get-LatestUpdate.

    .PARAMETER Path
        A destination path for downloading the cumulative updates to. This path must exist. Uses the current diretory by default.

    .EXAMPLE
        Get-LatestUpdate | Save-LatestUpdate

        Description:
        Retreives the latest Windows 10 Cumulative Update with Get-LatestUpdate and passes the array of updates to Save-LatestUpdate on the pipeline.
        Save-LatestUpdate then downloads the latest updates to the current directory.

    .EXAMPLE
        $Updates = Get-LatestUpdate -Build 14393
        Save-LatestUpdate -Updates $Updates -Path C:\Temp\Update

        Description:
        Retreives the latest Windows 10 build 14393 (1607) Cumulative Update with Get-LatestUpdate, saved to the variable $Updates.
        Save-LatestUpdate then downloads the latest updates to C:\Temp\Update.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Array])]
    Param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, `
                HelpMessage = "The array of updates from Get-LatestUpdate.")]
        [ValidateNotNullOrEmpty()]
        [Array] $Updates,
    
        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $False, `
                HelpMessage = "Specify a target path to download the update(s) to.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [String] $Path = $PWD
    )
    Begin {
        $Path = Get-ValidPath $Path
    } 
    Process {
        $Urls = $Updates | Select-UniqueUrl
        ForEach ( $url in $urls ) {
            $filename = Split-Path $url -Leaf
            $target = "$($Path)\$($filename)"
            Write-Verbose "Download target will be $target"
            $displayName = $Updates | Where-Object { $_.Url -eq $url } | Select-Object -ExpandProperty Note | Select-Object -First 1
            
            # If the update is not already downloaded, download it.
            If (!( Test-Path -Path $target )) {
                If ( Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue ) {
                    # If BITS is available, let us it
                    If ( $pscmdlet.ShouldProcess($(Split-Path $url -Leaf), "BitsDownload") ) {
                        Start-BitsTransfer -Source $url -Destination $target `
                            -Priority High -ErrorAction Continue -ErrorVariable $ErrorBits `
                            -DisplayName $displayName -Description "Downloading $($url)"
                    }
                }
                Else {
                    # BITS isn't available (likely PowerShell Core)
                    If ( $pscmdlet.ShouldProcess($url, "WebDownload") ) {
                        Invoke-WebRequest -Uri $url -OutFile $target
                    }
                }
            }
            Else {
                Write-Verbose "File exists: $target. Skipping download."
            }
        }
    }
    End {
        Write-Output $urls
    }
}
