
function Get-AuthToken {

  <#
  .SYNOPSIS
  This function is used to authenticate with the Graph API REST interface
  .DESCRIPTION
  The function authenticate with the Graph API Interface with the tenant name
  .EXAMPLE
  Get-AuthToken
  Authenticates you with the Graph API interface
  .NOTES
  NAME: Get-AuthToken
  #>

  [cmdletbinding()]

  param
  (
    [Parameter(Mandatory = $true)]
    $User,
    $Password
  )

  $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
  $tenant = $userUpn.Host
  #$tenant = "c8ce4011-e689-48a2-ba74-46fe334d73ff"

  Write-Host "Checking for AzureAD module..."

  $AadModule = Get-Module -Name "AzureAD" -ListAvailable
  if ($null -eq $AadModule) {
    Write-Host "AzureAD PowerShell module not found, looking for AzureADPreview"
    $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable
  }
  if ($null -eq $AadModule) {
    write-host
    write-host "AzureAD Powershell module not installed..." -f Red
    write-host "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt" -f Yellow
    write-host "Script can't continue..." -f Red
    write-host
    exit
  }

  # Getting path to ActiveDirectory Assemblies
  # If the module count is greater than 1 find the latest version

  if ($AadModule.count -gt 1) {
    $Latest_Version = ($AadModule | select version | Sort-Object)[-1]
    $aadModule = $AadModule | ? { $_.version -eq $Latest_Version.version }
    # Checking if there are multiple versions of the same module found

    if ($AadModule.count -gt 1) {
      $aadModule = $AadModule | select -Unique
    }

    $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
  }
  else {
    $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
  }

  [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
  [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
  #$clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547" # Intune
  $clientId = "5344033d-165b-4788-bae0-a0d1e5f27787" # Custom
  $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
  $resourceAppIdURI = "https://graph.microsoft.com"
  $authority = "https://login.microsoftonline.com/$Tenant"

  try {
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
    # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
    # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession

    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")

      $UserPassword = $Password | ConvertTo-SecureString -AsPlainText -Force
      $userCredentials = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential -ArgumentList $userUPN, $UserPassword
      $authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $resourceAppIdURI, $clientid, $userCredentials).Result


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
      Write-Host
      Write-Host "Authorization Access Token is null, please re-run authentication..." -ForegroundColor Red
      Write-Host
      break
    }
  }
  catch {
    write-host $_.Exception.Message -f Red
    write-host $_.Exception.ItemName -f Red
    write-host
    break
  }
}

####################################################

#region Authentication

$User = "pouyan.graph@condiciocloud.onmicrosoft.com"
$Password = "Ehk58HV^3ab@lsp3"

write-host

# Checking if authToken exists before running authentication
if ($global:authToken) {
  # Setting DateTime to Universal time to work in all timezones
  $DateTime = (Get-Date).ToUniversalTime()
  # If the authToken exists checking when it expires
  $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

  if ($TokenExpires -le 0) {
    write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
    write-host
    # Defining Azure AD tenant name, this is the name of your Azure Active Directory (do not use the verified domain name)
    if ($User -eq $null -or $User -eq "") {
      $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
      Write-Host
    }
    $global:authToken = Get-AuthToken -User $User -Password $Password
  }
}
else {
  if ($User -eq $null -or $User -eq "") {
    $User = Read-Host -Prompt "Please specify your user principal name for Azure Authentication"
    Write-Host
  }
  # Getting the authorization token
  $global:authToken = Get-AuthToken -User $User -Password $Password
}

#endregion

####################################################


$uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations"
Write-Verbose $uri
(Invoke-RestMethod -Uri $uri –Headers $authToken –Method Get).Value
