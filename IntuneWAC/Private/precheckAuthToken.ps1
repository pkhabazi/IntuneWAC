function precheckAuthToken {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER AuthToken
        Coming soon
    .EXAMPLE
    precheckAuthToken -Authtoken $token
    Authenticates you with the Graph API interface
    .NOTES
    NAME: precheckAuthToken
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [Hashtable]$Authtoken
    )

    process {
        # Checking if authToken exists before running authentication
        if ($Authtoken) {
            # Setting DateTime to Universal time to work in all timezones
            Write-Verbose "Token exists, testing the validation"
            $dateTime = (Get-Date).ToLocalTime()
            # If the authToken exists checking when it expires
            $tokenExpires = ($token.ExpiresOn - $dateTime).Minutes

            if ($tokenExpires -le 0) {
                Write-Error "Authentication Token expired $tokenExpires minutes ago, Run Get-AuthToken first!" -ErrorAction Stop
            }
            elseif ($tokenExpires -le 10) {
                Write-Verbose "Token expires in less than $($tokenExpires) minutes, renewing token"
                $token = Get-authToken -RefreshToken $Authtoken.refresh_token -ClientId $Authtoken.ClientId -TenantId $Authtoken.TenantId -Authtype User
                if ($token) {
                    return $token
                }
                else {
                    Write-Error "Unable to renew token" -ErrorAction Stop
                }
            }
            else {
                Write-Verbose "Token is valid for $($tokenExpires) minutes"
            }
        }
        else {
            Write-Verbose "authToken doesn't exists, requesting"
            Write-Error "authToken is empty, Run Get-AuthToken first!" -ErrorAction Stop
        }
        #endregion
    }
}
