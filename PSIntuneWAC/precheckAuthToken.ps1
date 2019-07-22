function precheckAuthToken {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER AuthToken
        Coming soon
    .EXAMPLE
    precheckAuthToken -Authtoken $Authtoken
    Authenticates you with the Graph API interface
    .NOTES
    NAME: precheckAuthToken
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [Hashtable]$Authtoken
    )

    begin {

    }

    process {
        # Checking if authToken exists before running authentication
        if ($Authtoken) {
            # Setting DateTime to Universal time to work in all timezones
            Write-Verbose "authToken exists, testing the validation"
            $dateTime = (Get-Date).ToUniversalTime()
            # If the authToken exists checking when it expires
            $tokenExpires = ($Authtoken.ExExpiresin - $dateTime).Minutes

            if ($tokenExpires -le 0) {
                Write-Error "Authentication Token expired $tokenExpires minutes ago, Run Get-AuthToken first!"

            }
            else {
                Write-Verbose "Token expires in $($tokenExpires) minutes"
            }
        }
        else {
            # Getting the authorization token
            Write-Verbose "authToken doesn't exists, requesting"
            Write-Error "authToken is empty, Run Get-AuthToken first!"
        }
        #endregion
    }
}
