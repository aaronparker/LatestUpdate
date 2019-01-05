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

        .PARAMETER ForceWebRequest
            Forces the use of Invoke-WebRequest over Start-BitsTransfer on Windows PowerShell.

        .EXAMPLE
            Get-LatestUpdate | Save-LatestUpdate

            Description:
            Retreives the latest Windows 10 Cumulative Update with Get-LatestUpdate and passes the array of updates to Save-LatestUpdate on the pipeline.
            Save-LatestUpdate then downloads the latest updates to the current directory.

        .EXAMPLE
            $Updates = Get-LatestUpdate -WindowsVersion Windows10 -Build 14393
            Save-LatestUpdate -Updates $Updates -Path C:\Temp\Update

            Description:
            Retreives the latest Windows 10 build 14393 (1607) Cumulative Update with Get-LatestUpdate, saved to the variable $Updates.
            Save-LatestUpdate then downloads the latest updates to C:\Temp\Update.

        .EXAMPLE
            $Updates = Get-LatestUpdate
            Save-LatestUpdate -Updates $Updates -Path C:\Temp\Update -ForceWebRequest

            Description:
            Retreives the latest Windows 10 build Cumulative Update with Get-LatestUpdate, saved to the variable $Updates.
            Save-LatestUpdate then downloads the latest updates to C:\Temp\Update using Invoke-WebRequest instead of Start-BitsTransfer.
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
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                If (!(Test-Path -Path $_ -PathType 'Container')) {
                    Throw "Cannot find path $_"
                }
                Return $True
            })]
        [String] $Path = $PWD,

        [Parameter(Mandatory = $False)]
        [switch] $ForceWebRequest
    )
    Begin {
        $Path = Get-ValidPath $Path
        $output = @()
    } 
    Process {

        # Step through each update in $Updates
        ForEach ($update in $Updates) {

            # Create the target file path where the update will be saved
            $filename = Split-Path $update.URL -Leaf
            $target = Join-Path $Path $filename
            $output += $target
            Write-Verbose "Download target will be $target"
            
            # If the update is not already downloaded, download it.
            If (!(Test-Path -Path $target)) {
                If ($ForceWebRequest -or (Test-PSCore)) {

                    # Running on PowerShell Core or ForceWebRequest
                    If ($pscmdlet.ShouldProcess($update.URL, "WebDownload")) {
                        try {
                            Invoke-WebRequest -Uri $update.URL -OutFile $target -UseBasicParsing -ErrorAction SilentlyContinue
                        }
                        catch {
                            Throw $_
                        }
                    }
                }
                Else {

                    # Running on Windows PowerShell
                    If ($pscmdlet.ShouldProcess($(Split-Path $update.URL -Leaf), "BitsDownload")) {
                        try {
                            Start-BitsTransfer -Source $update.URL -Destination $target `
                                -Priority High -ErrorAction SilentlyContinue -ErrorVariable $ErrorBits `
                                -DisplayName $update.Note -Description "Downloading $($update.URL)"
                        }
                        catch {
                            Throw $_
                        }
                    }
                }
            }
            Else {
                Write-Verbose "File exists: $target. Skipping download."
            }
        }
    }
    End {
        Write-Output $output
    }
}
