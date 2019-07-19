function precheckAuthToken {

    [cmdletbinding()]
    param (
        $authtoken
    )

    begin {

    }

    process {
        # Checking if authToken exists before running authentication
        if ($authToken) {
            # Setting DateTime to Universal time to work in all timezones
            Write-Verbose "authToken exists, testing the validation"
            $DateTime = (Get-Date).ToUniversalTime()
            # If the authToken exists checking when it expires
            $TokenExpires = ($authToken.ExExpiresin - $DateTime).Minutes

            if ($TokenExpires -le 0) {
                Write-Error "Authentication Token expired $TokenExpires minutes ago, Run Get-AuthToken first!"

            }
            else {
                Write-Verbose "Token expires in $($TokenExpires) minutes"
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
