function Backup-Intune {
    <#
    .SYNOPSIS
    This function is used to authenticate with the Graph API REST interface
    .DESCRIPTION
    The function authenticate with the Graph API Interface using username and password or using applicationID and Password
    .PARAMETER Param
     coming

    .EXAMPLE
    Get-authToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -Authtype Application
    Authenticates you with the Graph API interface

    .NOTES
    NAME: Backup-Intune
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [switch]$Param
    )

    if ($Param) {
        "Got param..."
    }
    else {
        "No param..."
    }
}
