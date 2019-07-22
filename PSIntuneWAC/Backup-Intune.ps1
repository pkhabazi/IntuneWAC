
function Backup-Intune {
    <#
    .SYNOPSIS
    This function is used to authenticate with the Graph API REST interface
    .DESCRIPTION
    The function authenticate with the Graph API Interface using username and password or using applicationID and Password
    .PARAMETER OptionalParameters
     coming

    .EXAMPLE
    Get-authToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -Authtype Application
    Authenticates you with the Graph API interface

    .NOTES
    NAME: Backup-Intune
    #>
    param (
        $OptionalParameters
    )
    begin {

    }
    process {
        Write-Output test
    }

}
