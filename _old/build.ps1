[cmdletbinding()]
param (
  [string]$username,

  [secureString]$password,

  [string]$yamlPath
)

Write-Output "Grabbing required modules.."
try {
  import-Module -Name Powershell-Yaml
  import-Module -Name Plaster
}
catch {
  Write-Error $_ -ErrorAction Stop
}

#region Config
$deviceConfigurationPath = "$PSScriptRoot\CON-$($config.client)\configuration"
$deviceCompliancePath = "$PSScriptRoot\CON-$($config.client)\compliance"
$deviceScriptPath = "$PSScriptRoot\CON-$($config.client)\scripts"
$plasterTemplatePath = "$PSScriptRoot\Intune-Plaster-Build"
$projectDestination = "$PSScriptRoot"
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
    $Password
  )

  $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
  #$tenant = $userUpn.Host
  $tenant = "c8ce4011-e689-48a2-ba74-46fe334d73ff"

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
  $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
  $resourceAppIdURI = "https://graph.microsoft.com"
  $authority = "https://login.microsoftonline.com/$Tenant"

  try {
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
    # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
    # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession

    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")

      $userCredentials = new-object Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential -ArgumentList $userUPN, $Password
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
Function Add-DeviceManagementPolicy {

  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory)]
    $authToken,

    [Parameter(Mandatory)]
    $json,

    [Parameter(Mandatory)]
    [ValidateSet('Configuration', 'Compliance', 'Script')]
    [string]$managementType

  )
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
    Write-Host "Posting $managementType policy.."
    $res = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $json -ContentType "application/json"
    return $res
  }
  catch {
    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd()
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    Write-Host
    break
  }
}
#endregion
try {
  #region Unattended Authentication
  $global:authToken = Get-AuthToken -User $username -Pass $password
  #endregion

  #region Build profile modules from templates
  $params = @{
    ClientName          = $config.client
    ClientDomain        = $config.tenantDomain
    ConfigPolicy        = $(if ($config.configPolicies) { $true } else { $false })
    confBitlocker       = $(if ($config.configPolicies -contains "bitlocker") { $true } else { $false })
    confCorpBranding    = $(if ($config.configPolicies.corporateBranding) { $true } else { $false })
    desktopImageUrl     = $(if ($config.configPolicies.corporateBranding) { $config.configPolicies.corporateBranding.desktopImageUrl })
    lockscreenImageUrl  = $(if ($config.configPolicies.corporateBranding) { $config.configPolicies.corporateBranding.lockscreenImageUrl })
    confDevRestrictions = $(if ($config.configPolicies.deviceRestrictions) { $true } else { $false })
    homepageUrl         = $(if ($config.configPolicies.deviceRestrictions) { $config.configPolicies.deviceRestrictions.homepageUrl } else { " " })
    confEndProtection   = $(if ($config.configPolicies.endpointProtection) { $true } else { $false })
    corporateMsgTitle   = $(if ($config.configPolicies.endpointProtection) { $config.configPolicies.endpointProtection.corporateMsgTitle } else { " " })
    corporateMsgText    = $(if ($config.configPolicies.endpointProtection) { $config.configPolicies.endpointProtection.corporateMsgText } else { " " })
    CompliancePolicy    = $(if ($config.compliancePolicies) { $true } else { $false })
    compBitlocker       = $(if ($config.compliancePolicies -contains "bitlocker") { $true } else { $false })
    scriptTimezone      = $(if ($config.scripts -contains "timezone") { $true } else { $false })
    scriptbitlocker     = $(if ($config.scripts -contains "bitlocker") { $true } else { $false })
    scriptonedrive      = $(if ($config.scripts -contains "onedrive") { $true } else { $false })
    scriptwallpaperFix  = $(if ($config.scripts -contains "wallpaperFix") { $true } else { $false })
  }
  invoke-plaster -TemplatePath $plasterTemplatePath -DestinationPath $projectDestination @params -Force
  #endregion
  #region Upload profile modules to tenant..
  Write-Host "Uploading Device configuration profiles to Intune.."
  foreach ($x in (Get-ChildItem $deviceConfigurationPath)) {
    $tmpJson = $null
    $tmpJson = Get-Content $x.FullName -raw
    $result = Add-DeviceManagementPolicy -authToken $authToken -json $tmpJson -managementType Configuration
    $result | ConvertTo-Yaml | Out-File -FilePath "$ENV:Temp\Configuration_$($x.Name -replace '.json','').yaml" -Encoding ascii
    $confLog = "$ENV:Temp\Configuration_$($x.Name -replace '.json','').yaml"
    Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Device Configuration Profile - $($x.Name -replace '.json','');]$confLog"
  }
  Write-Host "Uploading Device compliance policies to Intune.."
  foreach ($x in (Get-ChildItem $deviceCompliancePath)) {
    $tmpJson = $null
    $tmpJson = Get-Content $x.FullName -raw
    $result = Add-DeviceManagementPolicy -authToken $authToken -json $tmpJson -managementType Compliance
    $result | ConvertTo-Yaml | Out-File -FilePath "$ENV:Temp\Compliance_$($x.Name -replace '.json','').yaml" -Encoding ascii -Force
    $compLog = "$ENV:Temp\Compliance_$($x.Name -replace '.json','').yaml"
    Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Device Compliance Policy - $($x.Name -replace '.json','');]$compLog"
  }
  Write-Host "Uploading scripts to Intune.."
  foreach ($x in (Get-ChildItem $deviceScriptPath)) {
    $tmpJson = $null
    $tmpScript = $null
    $tmpEncScript = $null
    $tmpJson = Get-Content "$($x.FullName)\$($x.Name).json" -raw | ConvertFrom-Json
    $tmpScript = Get-Content "$($x.FullName)\$($x.Name).ps1" -raw
    $tmpEncScript = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$tmpScript"))
    $tmpJson | Add-Member -MemberType NoteProperty -Name "scriptContent" -Value $tmpEncScript
    $result = Add-DeviceManagementPolicy -authToken $authToken -json ($tmpJson | ConvertTo-Json -Depth 100) -managementType Script
    $result | ConvertTo-Yaml | Out-File -FilePath "$ENV:Temp\Script_$($x.Name -replace '.json','').yaml" -Encoding ascii -Force
    $scriptLog = "$ENV:Temp\Script_$($x.Name -replace '.json','').yaml"
    $scriptLogName = $x.Name | Split-Path
    Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Scripts - $($x.Name -replace '.json','');]$scriptLog"
  }
  #endregion
}
catch {
  Write-Warning $_
}
