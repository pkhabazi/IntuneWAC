Write-Output "Grabbing required modules.."
try {
  import-Module -Name Powershell-Yaml
  import-Module -Name Plaster
}
catch {
  Write-Error $_ -ErrorAction Stop
}


#region Config
$configPath = "$PSScriptRoot\Intune-Plaster-Build\templates\config-profiles"
$compPath = "$PSScriptRoot\Intune-Plaster-Build\templates\compliance-policies"
$scriptPath = "$PSScriptRoot\Intune-Plaster-Build\templates\scripts"

Write-Output $configPath, $compPath, $scriptPath
#endregion



#region Functions
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
    [System.Security.SecureString]$Pass
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
  $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547" # Intune
  #$clientId = "5619c1eb-c15e-4f29-b892-a8bc0dbe8229" # Custom
  #$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
  $resourceAppIdURI = "https://graph.microsoft.com"
  $authority = "https://login.microsoftonline.com/$Tenant"

  try {
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
    # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
    # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession

    #$platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")

    $userCredentials = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential -ArgumentList $userUPN, $Pass
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
      Write-Error "Authorization Access Token is null, please re-run authentication..." -ErrorAction Stop
      break
    }
  }
  catch {
    Write-Error $_.Exception.Message -ErrorAction Stop
    Write-Error $_.Exception.ItemName -ErrorAction Stop
    break
  }
}


function precheck {

  process {
    # Checking if authToken exists before running authentication
    if ($global:authToken) {
      # Setting DateTime to Universal time to work in all timezones
      Write-Output "authToken exists, testing the validation"
      $DateTime = (Get-Date).ToUniversalTime()
      # If the authToken exists checking when it expires
      $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

      if ($TokenExpires -le 0) {
        #Write-Warning "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
        # Defining Azure AD tenant name, this is the name of your Azure Active Directory (do not use the verified domain name)
        #$global:authToken = Get-AuthToken -User $username -Pass $password
        throw "Authentication Token expired $TokenExpires minutes ago, Run Get-AuthToken first!"

      }
    }
    else {
      # Getting the authorization token
      Write-Output "authToken doesn't exists, requesting"
      #$global:authToken = Get-AuthToken -User $username -Pass $password
      throw "authToken is empty, Run Get-AuthToken first!"
    }
    #endregion
  }
}

function Get-DeviceManagementPolicy {
  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory)]
    $authToken,

    [Parameter(Mandatory)]
    [ValidateSet('Configuration', 'Compliance', 'Script')]
    [string]$managementType

  )
  begin {
    precheck
  }
  process {
    switch ($managementType) {
      "Configuration" {
        $graphEndpoint = "deviceManagement/deviceConfigurations"
        break
      }
      "Compliance" {
        $graphEndpoint = "deviceManagement/deviceCompliancePolicies"
        break
      }
      "Script" {
        $graphEndpoint = "deviceManagement/deviceManagementScripts"
        break
      }
    }

    $graphApiVersion = "Beta"
    Write-Verbose "Resource: $graphEndpoint"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)"

    try {
      if ($managementType -eq "Script") {
        $response = @()
        $tmpRes = Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken | select-object value -ExpandProperty value
        foreach ($x in $tmpRes) {
          $response += Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)/$($x.id)" -Headers $authToken
        }
        return $response
      }
      else {
        $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken | select-object value -ExpandProperty value
        if ($response) {
          Write-Host "Found $($response.count) objects"
          return $response
        }
        else {
          throw "Nothing returned.."
        }
      }
    }
    catch {
      $ex = $_.Exception
      Write-Warning $ex
      break
    }
  }




}

function Export-DeviceManagementPolicy {
  param (
    $path,

    [Parameter(Mandatory)]
    [ValidateSet('Configuration', 'Compliance', 'Script')]
    [string]$ConfType,

    [Parameter(Mandatory)]
    $authToken
  )

  begin {
    precheck
  }
  process {
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
        if ($null -eq $username -or $username -eq "") {
          Write-Error "no user found" -ErrorAction Stop
        }
        $global:authToken = Get-AuthToken -User $username -Password $Password
      }
    }
    else {
      if ($null -eq $username -or $username -eq "") {
        Write-Error "no user found" -ErrorAction Stop
      }
      # Getting the authorization token
      $global:authToken = Get-AuthToken -User $username -Password $Password
    }
    #endregion

    if ($ConfType -eq 'Configuration' -or $ConfType -eq 'All') {
      $configPath = "$path\Intune-Plaster-Build\templates\config-profiles"
      $deviceConfiguration = Get-DeviceManagementPolicy -authToken $authToken -managementType Configuration -Verbose | Select-Object * -ExcludeProperty value
      foreach ($d in $deviceConfiguration) {
        $d | Select-Object * -ExcludeProperty id, lastModifiedDateTime, roleScopeTagIds, supportsScopeTags, createdDateTime, version | ConvertTo-Json -Depth 100 | Out-File -FilePath "$configPath\$($d.displayName)`.json" -Encoding ascii -Force
      }
    }

    if ($ConfType -eq 'Compliance' -or $ConfType -eq 'All') {
      $deviceCompliance = Get-DeviceManagementPolicy -authToken $authToken -managementType Compliance | Select-Object * -ExcludeProperty value
      foreach ($d in $deviceCompliance) {
        $d | Select-Object * -ExcludeProperty id, lastModifiedDateTime, roleScopeTagIds, supportsScopeTags, createdDateTime, version | ConvertTo-Json -Depth 100 | Out-File -FilePath "$compPath\$($d.displayName)`.json" -Encoding ascii -Force
      }
    }

    if ($ConfType -eq 'Compliance' -or $ConfType -eq 'All') {
      $scripts = Get-DeviceManagementPolicy -authToken $authToken -managementType Script | Select-Object * -ExcludeProperty value
      foreach ($d in $scripts) {
        $tmpJson = $d | select-object '@odata.context', displayName, description, runAsAccount, enforceSignatureCheck, fileName, runAs32Bit;
        New-Item "$scriptPath\$($d.DisplayName)" -ItemType Directory -Force | Out-Null;
        $tmpJson | ConvertTo-Json -Depth 100 | Out-File -FilePath "$scriptPath\$($d.displayName)\$($d.displayName)`.json" -Encoding ascii -Force;
        [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String("$($d.scriptContent)")) | Out-File -FilePath "$scriptPath\$($d.displayName)\$($d.displayName)`.ps1" -Encoding ascii -Force;
      }
    }
  }

}

function Import-DeviceManagementPolicy {
  param (

  )
  begin {
    precheck
  }
  process {

  }
}
#endregion
