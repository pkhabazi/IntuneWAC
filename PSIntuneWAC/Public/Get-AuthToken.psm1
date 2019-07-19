function Get-AuthToken {
    <#
    .SYNOPSIS
    This function is used to authenticate with the Graph API REST interface
    .DESCRIPTION
    The function authenticate with the Graph API Interface using username and password or using applicationID and Password
    .PARAMETER userName
     coming
    .PARAMETER password
    coming
    .PARAMETER clientId
    coming
    .PARAMETER clientSecret
    coming
    .PARAMETER tenantId
    coming
    .PARAMETER refresh
    coming
    .PARAMETER Authtype
    coming

    .EXAMPLE
    Get-AuthToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -Authtype Application
    Authenticates you with the Graph API interface
    .EXAMPLE
    Get-AuthToken -userName "pouyan.graph@condiciocloud.onmicrosoft.com" -password "Ehk58HV^3ab@lsp3" -tenantId $tenantId -Authtype User -Verbose
    Authenticates you with the Graph API interface
    .NOTES
    NAME: Get-AuthToken
    #>

    [cmdletbinding()]
    param (
        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$userName,

        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$password,

        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$clientId,

        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$clientSecret,

        # Parameter help description
        [Parameter(mandatory = $true)]
        [string]$tenantId,

        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$refresh,

        # Parameter help description
        [Parameter(Mandatory = $true)]
        [ValidateSet('Application', 'User')]
        [string]$Authtype
    )

    begin {
    }

    process {

        $resourceURL = "https://graph.microsoft.com"

        switch ($Authtype) {
            "Application" {
                $_AuthType = 'Application'
            }
            "User" {
                $_AuthType = 'User'
            }
            Default { }
        }

        if ($clientId -eq '') {
            $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
            Write-Verbose "Using default Client ID: $($clientId)"
        }
        else {
            Write-Verbose "Using Custom Client ID: $($clientId)"
        }

        ###############################
        if ($_AuthType -eq 'User') {
            Write-Verbose "Loging in with Userame and Password"

            if ($refresh) {
                $body = @{
                    resource      = $resourceURL
                    client_id     = $clientId
                    grant_type    = "refresh_token"
                    username      = $userName
                    scope         = "openid"
                    password      = $password
                    refresh_token = $refresh
                }
            }
            else {
                $body = @{
                    resource   = $resourceURL
                    client_id  = $clientId
                    grant_type = "password"
                    username   = $userName
                    scope      = "openid"
                    password   = $password
                }
            }

            $uri = "https://login.microsoftonline.com/$tenantId/oauth2/token"

            try {
                Write-Verbose "Connecting to uri: $($uri)"

                $response = Invoke-RestMethod -Method post -Uri $uri -Body $body

                if ($response.Access_Token) {

                    Write-Verbose "Creating header for Authorization token"

                    $authToken = @{
                        'Content-Type'  = 'application/json'
                        'Authorization' = "Bearer " + $response.Access_Token
                        'ExpiresOn'     = $response.expires_in
                    }
                    return $authToken
                }
                else {
                    Write-Verbose $_
                    Write-Error "Unale to authenticate" -ErrorAction Stop
                }
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to connect" -ErrorAction Stop
            }
        }

        ###############################
        if ($_AuthType -eq 'Application') {

            Write-Verbose "Logging in with appplicationID and token"

            if ($refresh) {
                $body = @{
                    client_id     = $clientId
                    scope         = "https://graph.microsoft.com/.default"
                    client_secret = $clientSecret
                    grant_type    = "refresh_token"
                    refresh_token = $refresh
                }
            }
            else {
                $body = @{
                    client_id     = $clientId
                    scope         = "https://graph.microsoft.com/.default"
                    client_secret = $clientSecret
                    grant_type    = "client_credentials"
                }
            }

            $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
            $response = Invoke-RestMethod -Method post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing -ErrorAction SilentlyContinue

            if ($response.Access_Token) {

                Write-Verbose "Creating header for Authorization token"

                $authToken = @{
                    'Content-Type'  = 'application/json'
                    'Authorization' = "Bearer " + $response.Access_Token
                    'ExpiresOn'     = $response.expires_in
                    'ExExpiresin'   = (Get-Date).ToUniversalTime().AddMinutes('60')
                }
                return $authToken
            }
            else {
                Write-Verbose $_
                Write-Error "Unable to authenticate" -ErrorAction Stop

            }
        }
    }
}
