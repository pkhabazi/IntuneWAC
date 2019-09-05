function precheckAuthToken {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .EXAMPLE
    precheckAuthToken -Authtoken $token
    Authenticates you with the Graph API interface
    .NOTES
    NAME: precheckAuthToken
    #>

    [cmdletbinding()]
    param (
    )

    process {
        # Checking if authToken exists before running authentication
        if ($script:authtoken) {
            # Setting DateTime to Universal time to work in all timezones
            Write-Verbose "Token exists, testing the validation"
            $dateTime = (Get-Date).ToLocalTime()
            # If the authToken exists checking when it expires
            $tokenExpires = ($script:authtoken.ExpiresOn - $dateTime).Minutes

            if ($tokenExpires -le 0) {
                Write-Error "Authentication Token expired $tokenExpires minutes ago, Run Get-AuthToken first!" -ErrorAction Stop
            }
            elseif ($tokenExpires -le 10) {
                Write-Verbose "Token expires in less than $($tokenExpires) minutes, renewing token"
                $script:authtoken = Get-authToken -RefreshToken $script:authtoken.refresh_token -ClientId $script:authtoken.ClientId -TenantId $script:authtoken.TenantId -Authtype User
                if ($script:authtoken) {
                    return $script:authtoken
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
