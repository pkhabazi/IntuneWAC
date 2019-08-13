function Set-AdminConsent {
    <#
    .SYNOPSIS
    This function is used to authenticate with the Graph API REST interface
    .DESCRIPTION
    The function authenticate with the Graph API Interface with the tenant name
    .PARAMETER User
        COMING SOON
    .EXAMPLE
    Get-AuthToken
    Authenticates you with the Graph API interface
    .NOTES
    NAME: Get-AuthToken
    #>

    [cmdletbinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [string]$User
    )

    process {
        $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
        $tenant = $userUpn.Host
        Write-Verbose "Checking for AzureAD module..."
        $aAdModule = Get-Module -Name "AzureAD" -ListAvailable -ErrorAction SilentlyContinue

        if ($null -eq $aAdModule) {
            Write-Warning "AzureAD PowerShell module not found, looking for AzureADPreview"
            $aAdModule = Get-Module -Name "AzureADPreview" -ListAvailable -ErrorAction SilentlyContinue
        }

        if ($null -eq $aAdModule) {
            Write-Error "AzureAD Powershell module not installed..."
            Write-Error "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt"
            Write-Error "Script can't continue..." -ErrorAction Stop
        }

        # Getting path to ActiveDirectory Assemblies
        # If the module count is greater than 1 find the latest version
        if ($aAdModule.count -gt 1) {
            $latest_Version = ($aAdModule | Select-Object version | Sort-Object)[-1]
            $aAdModule = $aAdModule | Where-Object version -eq $latest_Version.version

            # Checking if there are multiple versions of the same module found
            if ($aAdModule.count -gt 1) {
                $aAdModule = $aAdModule | Select-Object -Unique
            }
            $adal = Join-Path $aAdModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
            $adalforms = Join-Path $aAdModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
        }
        else {
            $adal = Join-Path $aAdModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
            $adalforms = Join-Path $aAdModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
        }

        [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
        [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

        $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
        $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
        $resourceAppIdURI = "https://graph.microsoft.com"
        $authority = "https://login.microsoftonline.com/$tenant"

        try {
            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
            # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
            # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession
            $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
            $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")
            $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters, $userId, "prompt=admin_consent").Result

            if ($authResult.AccessToken) {
                # Creating header for Authorization token
                $authHeader = @{
                    'Content-Type'  = 'application/json'
                    'Authorization' = "Bearer " + $authResult.AccessToken
                    'ExpiresOn'     = $authResult.ExpiresOn
                }
                return $authHeader
            }
            else {
                Write-Error "Authorization Access Token is null, please re-run authentication..." -ErrorAction Stop
            }
        }
        catch {
            Write-Error $_.Exception.Message
            Write-Error $_.Exception.ItemName -ErrorAction Stop
        }
    }
}
