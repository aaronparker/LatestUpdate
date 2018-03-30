Function Save-LatestUpdate {
    <#
    .SYNOPSIS
        Downloads the latest cumulative update passed from Get-LatestUpdate.

    .DESCRIPTION
        Downloads the latest cumulative update passed from Get-LatestUpdate to a local folder. The update can then be imported into an MDT share with Import-LatestUpdate.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .PARAMETER Updates
        The array of latest cumulative updates retreived by Get-LatestUpdate.

    .PARAMETER Path
        A destination path for downloading the cumulative updates to. This path must exist.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Array])]
    Param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, `
                HelpMessage = "The array of updates from Get-LatestUpdate.")]
        [ValidateNotNullOrEmpty()]
        [array]$Updates,
    
        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $False, `
                HelpMessage = "Specify a target path to download the update(s) to.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$Path = $PWD
    )
    Begin {
        $Path = Get-ValidPath $Path
    } 
    Process {
        $Urls = $Updates | Select-UniqueUrl
        Write-Verbose "URL count is: $Urls.Count"
        ForEach ( $Url in $Urls ) {
            $Filename = Split-Path $Url -Leaf
            $Target = "$($Path)\$($Filename)"
            $DisplayName = $Updates | Where-Object { $_.Url -eq $Url } | Select-Object -ExpandProperty Note | Select-Object -First 1
            Write-Verbose "`t`tDownload target will be $Target"
    
            If (!(Test-Path -Path $Target)) {
                If (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
                    If ($pscmdlet.ShouldProcess($(Split-Path $Url -Leaf), "BitsDownload")) {
                        Start-BitsTransfer -Source $Url -Destination $Target `
                            -Priority High -ErrorAction Continue -ErrorVariable $ErrorBits `
                            -DisplayName $DisplayName -Description "Downloading $($Url)"
                    }
                }
                Else {
                    If ($pscmdlet.ShouldProcess($Url, "WebDownload")) {
                        Invoke-WebRequest -Uri $Url -OutFile $Target
                    }
                }
            }
            Else {
                Write-Verbose "File exists: $Target. Skipping download."
            }
        }
    }
    End {
        Write-Output $Urls
    }
}