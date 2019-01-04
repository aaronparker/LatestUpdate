Function Get-KbUpdateArray {
    <#
        .SYNOPSIS
            Constructs a table with KB article, Update Id number and Update description from provided HTML links

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Links
            An object containing links filtered from a HTML object.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [PSCustomObject] $Links,

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String] $KB
    )

    # RegEx to grab text within <a/> tags in HTML
    [regex] $rx = "<a[^>]*>([^<]+)<\/a>"
    
    #region Contruct a table with KB, Id and Update description
    Write-Verbose -Message "Contructing temporary table with KB, ID and URL."
    $table = $Links | Where-Object ID -match '_link' | `
        Select-Object @{n = "KB"; e = {"KB$KB"}}, @{n = "Id"; e = {$_.id.Replace('_link', '')}}, `
    @{n = "Note"; e = {(($_.outerHTML -replace $rx, '$1').TrimStart()).TrimEnd()}}
    #endregion

    # Return the table to the pipeline
    Write-Output -InputObject $table
}
