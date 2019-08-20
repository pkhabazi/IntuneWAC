function Get-AuthToken {
    <#
    .SYNOPSIS
    This function is used to authenticate with the Graph API REST interface
    .DESCRIPTION
    The function authenticate with the Graph API Interface using username and password or using applicationID and Password
    .PARAMETER UserName
     coming
    .PARAMETER Password
    coming
    .PARAMETER ClientId
    coming
    .PARAMETER ClientSecret
    coming
    .PARAMETER TenantId
    coming
    .PARAMETER Refresh
    coming
    .PARAMETER Authtype
    coming
    .PARAMETER RefreshToken
    coming

    .EXAMPLE
    Get-authToken -clientId "clientId" -clientSecret "clientSecret" -tenantId "tenantID" -Authtype Application
    Authenticates you with the Graph API interface
    .EXAMPLE
    Get-authToken -userName "UserName" -password "Password" -tenantId "tenantID" -Authtype User -Verbose
    Authenticates you with the Graph API interface
    .NOTES
    NAME: Get-authToken
    #>

    [cmdletbinding()]
    param (
        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$UserName,

        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$Password,

        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$ClientId,

        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$ClientSecret,

        # Parameter help description
        [Parameter(mandatory = $true)]
        [string]$TenantId,

        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$RefreshToken,

        # Parameter help description
        [Parameter(Mandatory = $true)]
        [ValidateSet('Application', 'User')]
        [string]$Authtype
    )

    begin {
    }

    process {

        $resourceUri = "https://graph.microsoft.com"

        switch ($Authtype) {
            "Application" {
                $AuthType = 'Application'
            }
            "User" {
                $AuthType = 'User'
            }
            Default { }
        }

        if ($ClientId -eq '') {
            # Use default MS Intune Graph Client ID
            $ClientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
            Write-Verbose "Using default Client ID: $($ClientId)"
        }
        else {
            Write-Verbose "Using Custom Client ID: $($ClientId)"
        }

        ###############################
        if ($AuthType -eq 'User') {
            Write-Verbose "Loging in with Userame and Password"

            if ($RefreshToken) {
                $body = @{
                    resource      = $resourceUri
                    client_id     = $ClientId
                    grant_type    = "refresh_token"
                    scope         = "openid"
                    refresh_token = $RefreshToken
                }
            }
            else {
                $body = @{
                    resource   = $resourceUri
                    client_id  = $ClientId
                    grant_type = "password"
                    username   = $UserName
                    scope      = "openid"
                    password   = $Password
                }
            }

            $uri = "https://login.microsoftonline.com/$TenantId/oauth2/token"

            try {
                Write-Verbose "Connecting to uri: $($uri)"

                $response = Invoke-RestMethod -Method post -Uri $uri -Body $body

                if ($response.Access_Token) {

                    Write-Verbose "Creating header for Authorization token"

                    $authToken = @{
                        'Content-Type'  = 'application/json'
                        'Authorization' = "Bearer " + $response.Access_Token
                        'ExpiresOn'     = ([timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($response.expires_on)))
                        'ClientId'      = $ClientId
                        'refresh_token' = $response.refresh_token
                        'TenantId'      = $TenantId
                    }
                    Write-Verbose $authToken
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
        if ($AuthType -eq 'Application') {

            Write-Verbose "Logging in with appplicationID and token"

            if ($Refresh) {
                $body = @{
                    client_id     = $ClientId
                    scope         = "https://graph.microsoft.com/.default"
                    client_secret = $ClientSecret
                    grant_type    = "refresh_token"
                    refresh_token = $refresh
                }
            }
            else {
                $body = @{
                    client_id     = $ClientId
                    scope         = "https://graph.microsoft.com/.default"
                    client_secret = $ClientSecret
                    grant_type    = "client_credentials"
                }
            }

            $uri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
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
