$clientId = "514e80b8-f8eb-4dbf-a11e-3d680716473b"
$tenantId = "c8ce4011-e689-48a2-ba74-46fe334d73ff"
$clientSecret = 'emH.yXnv/Z-EhRe[PnmAjLBxBs53dS31'

$token = Get-AuthToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -Authtype Application
$tokenuser = Get-AuthToken -userName "pouyan.graph@condiciocloud.onmicrosoft.com" -password "Ehk58HV^3ab@lsp3" -tenantId $tenantId -Authtype User -Verbose

#region Functions
function precheckAuthToken {

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

function New-CustomIntuneApplication {
    param (
        # Parameter help description
        [Parameter(mandatory = $true)]
        [string]$userName,

        # Parameter help description
        [Parameter(mandatory = $true)]
        [string]$ApplicationName
    )


}

function Set-AdminConsent {
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

    # Parameter help description
    param (
        [Parameter(Mandatory = $true)]
        [string]$User
    )

    $userUpn = New-Object "System.Net.Mail.MailAddress" -ArgumentList $User
    $tenant = $userUpn.Host
    Write-Output "Checking for AzureAD module..."
    $AadModule = Get-Module -Name "AzureAD" -ListAvailable -ErrorAction SilentlyContinue

    if ($null -eq $AadModule) {
        Write-Warning "AzureAD PowerShell module not found, looking for AzureADPreview"
        $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable -ErrorAction SilentlyContinue
    }

    if ($null -eq $AadModule) {
        Write-Error "AzureAD Powershell module not installed..."
        Write-Error "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt"
        Write-Error "Script can't continue..." -ErrorAction Stop
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

    $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $resourceAppIdURI = "https://graph.microsoft.com"
    $authority = "https://login.microsoftonline.com/$Tenant"

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

Function Add-DeviceManagementPolicy {

    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        $json,

        [Parameter(Mandatory)]
        [ValidateSet('Configuration', 'Compliance', 'Script')]
        [string]$managementType

    )

    begin {
        precheckAuthToken
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
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)"

        try {
            Write-Verbose "Connecting to endpoint: $($graphEndpoint.Split('/')[1])"
            Write-Verbose "Connecting using fully uri: $($uri)"

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
            Write-Verbose "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
            Write-Error "Response content:`n$responseBody" -ErrorAction Stop
        }
    }


}

function Get-DeviceManagementPolicy {
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $authToken,

        [Parameter(Mandatory)]
        [ValidateSet('Configuration', 'Compliance', 'Script')]
        [string]$managementType

    )

    begin {
        precheckAuthToken
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

        Write-Verbose "Connicting to uri: $($uri)"

        try {
            if ($managementType -eq "Script") {
                Write-Verbose "Getting Device Management Script"
                $response = @()
                $tmpRes = Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken | select-object value -ExpandProperty value
                if ($tmpRes) {
                    foreach ($x in $tmpRes) {
                        $response += Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)/$($x.id)" -Headers $authToken -ContentType "application/json"
                    }
                    return $response
                }
                else {
                    Write-Verbose "No Scripts found to return"
                }
            }
            else {
                Write-Verbose "Getting Device Management Configuration and/or Comliance Policy"
                $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $authToken | select-object value -ExpandProperty value
                if ($response) {
                    Write-Verbose "Found $($response.count) objects for $($managementType)"
                    return $response
                }
                else {
                    Write-Verbose "nothing to return"
                }
            }
        }
        catch {
            Write-Verbose $_.Exception
            Write-Error "Unable to get dat from graph" -ErrorAction Stop
        }
    }
}

function Invoke-PlasterManifest {
    param (
    )

    begin {
        $plasterTemplatePath = "$PSScriptRoot\Intune-Plaster-Build"
        $projectDestination = "$PSScriptRoot"

        try {
            Import-Module -Name Powershell-Yaml
            Import-Module -Name Plaster
        }
        catch {
            Write-Warning "Run Install-Module Powershell-Yaml, Plaster -Scope CurrentUser -Force"
            Write-Error $_ -ErrorAction Stop
        }
    }

    process {
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

        Invoke-Plaster -TemplatePath $plasterTemplatePath -DestinationPath $projectDestination @params -Force
    }
}

function Import-IntuneConfig {

    [cmdletbinding()]
    param (
        [string]$yamlConfig,
        [switch]$azDevOps
    )

    begin {
        # test nog schrijven
        $deviceConfigurationPath = "$PSScriptRoot\$($config.client)\configuration"
        $deviceCompliancePath = "$PSScriptRoot\$($config.client)\compliance"
        $deviceScriptPath = "$PSScriptRoot\$($config.client)\scripts"
    }

    process {

        try {
            $config = Get-Content $yamlPath -raw | ConvertFrom-Yaml
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to read Yaml File $($yamlConfig)" -ErrorAction Stop
        }

        try {
            $deviceConfiguration = Get-ChildItem $deviceConfigurationPath
            $deviceCompliance = Get-ChildItem $deviceCompliancePath
            $deviceScript = Get-ChildItem $deviceScriptPath
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get JSON files" -ErrorAction Stop
        }

        Write-Output "Uploading Device configuration profiles to Intune.."
        if ($deviceConfiguration.count -ge 1) {
            foreach ($x in $deviceConfiguration) {
                $tmpJson = $null
                $tmpJson = Get-Content $x.FullName -raw
                $result = Add-DeviceManagementPolicy -authToken $authToken -json $tmpJson -managementType Configuration
                $result | ConvertTo-Yaml | Out-File -FilePath "$ENV:Temp\Configuration_$($x.Name -replace '.json','').yaml" -Encoding ascii

                if ($azDevOps) {
                    $confLog = "$ENV:Temp\Configuration_$($x.Name -replace '.json','').yaml"
                    Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Device Configuration Profile - $($x.Name -replace '.json','');]$confLog"
                }
            }
        }
        else {
            Write-Verbose "No Device configuration profiles found in $($deviceConfigurationPath) for upload"
        }

        Write-Output "Uploading Device compliance policies to Intune.."
        if ($deviceCompliance.count -ge 1) {
            foreach ($x in (Get-ChildItem $deviceCompliance)) {
                $tmpJson = $null
                $tmpJson = Get-Content $x.FullName -raw
                $result = Add-DeviceManagementPolicy -authToken $authToken -json $tmpJson -managementType Compliance
                $result | ConvertTo-Yaml | Out-File -FilePath "$ENV:Temp\Compliance_$($x.Name -replace '.json','').yaml" -Encoding ascii -Force

                if ($azDevOps) {
                    $compLog = "$ENV:Temp\Compliance_$($x.Name -replace '.json','').yaml"
                    Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Device Compliance Policy - $($x.Name -replace '.json','');]$compLog"
                }
            }
        }
        else {
            Write-Verbose "No Device configuration profiles found in $($deviceCompliancePath) for upload"
        }

        Write-Output "Uploading scripts to Intune.."
        if ($deviceScript.count -ge 1) {
            foreach ($x in $deviceScriptPath) {
                $tmpJson = $null
                $tmpScript = $null
                $tmpEncScript = $null
                $tmpJson = Get-Content "$($x.FullName)\$($x.Name).json" -raw | ConvertFrom-Json
                $tmpScript = Get-Content "$($x.FullName)\$($x.Name).ps1" -raw
                $tmpEncScript = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$tmpScript"))
                $tmpJson | Add-Member -MemberType NoteProperty -Name "scriptContent" -Value $tmpEncScript
                $result = Add-DeviceManagementPolicy -authToken $authToken -json ($tmpJson | ConvertTo-Json -Depth 100) -managementType Script
                $result | ConvertTo-Yaml | Out-File -FilePath "$ENV:Temp\Script_$($x.Name -replace '.json','').yaml" -Encoding ascii -Force

                if ($azDevOps) {
                    $scriptLog = "$ENV:Temp\Script_$($x.Name -replace '.json','').yaml"
                    $scriptLogName = $x.Name | Split-Path
                    Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Scripts - $($x.Name -replace '.json','');]$scriptLogName"

                }
            }
        }
        else {
            Write-Verbose "No Device configuration profiles found in $($deviceScriptPath) for upload"
        }
    }
}

function Export-IntuneConfig {
    <#
    .SYNOPSIS
    This function is used to Export the current configuration
    .DESCRIPTION
    The function exports the current configuration of Intune
    .Parameter FilePath
    specify the path where you want to export the configuration to
    .Parameter ConfType
    specify which type of config type you want to export: 'Configuration', 'Compliance', 'Script', 'All'
    .EXAMPLE
    Export-IntuneConfig -ConfType All -authToken $token -FilePath "C:\sources\pkm-intune\demo" -Verbose
    Export Current configuration to spicified folder
    .EXAMPLE
    Export-IntuneConfig -ConfType All -authToken $token -FilePath "C:\sources\pkm-intune\demo"
    Export Current configuration with verbose support
    .NOTES
    NAME: Export-IntuneConfig
    #>

    param (
        # Parameter help description
        [Parameter(mandatory = $false)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [ValidateSet('Configuration', 'Compliance', 'Script', 'All')]
        [string]$ConfType,

        $authToken
    )

    begin {
        #precheckAuthToken

        if ($FilePath) { $FilePath = $FilePath.TrimEnd('\') } else { $FilePath = $PSScriptRoot }

        if (Test-Path $FilePath) {
            Write-Verbose "Export files to $($FilePath)"
        }
        else {
            Write-Verbose "$($FilePath) doesn't exists, creating folder.."
            try {
                New-Item $FilePath -ItemType Directory -Force
                Write-Verbose "Created directory $($FilePath)"
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to create directory $($FilePath)"
            }
        }
    }

    process {
        if ($ConfType -eq 'Configuration' -or $ConfType -eq 'All') {

            $configPath = "$FilePath\Intune-Plaster-Build\templates\config-profiles"

            if (Test-Path $configPath) {
                Write-Verbose "Exporting to $($configPath)"
            }
            else {
                Write-Verbose "Creating folder $($configPath)"
                try {
                    New-Item -Path $configPath -ItemType Directory -Force
                    Write-Verbose "Folder $($configPath) created"
                }
                catch {
                    Write-Error "Unable to create folder" -ErrorAction Stop
                }
            }

            $deviceConfiguration = Get-DeviceManagementPolicy -authToken $authToken -managementType Configuration -Verbose | Select-Object * -ExcludeProperty value
            foreach ($d in $deviceConfiguration) {
                $d | Select-Object * -ExcludeProperty id, lastModifiedDateTime, roleScopeTagIds, supportsScopeTags, createdDateTime, version | ConvertTo-Json -Depth 100 | Out-File -FilePath "$configPath\$($d.displayName)`.json" -Encoding ascii -Force
            }
        }

        if ($ConfType -eq 'Compliance' -or $ConfType -eq 'All') {

            $compPath = "$FilePath\Intune-Plaster-Build\templates\compliance-policies"

            if (Test-Path $compPath) {
                Write-Verbose "Exporting to $($compPath)"
            }
            else {
                Write-Verbose "Creating folder $($compPath)"
                try {
                    New-Item -Path $compPath -ItemType Directory -Force
                    Write-Verbose "Folder $($compPath) created"
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Unable to create folder" -ErrorAction Stop
                }
            }

            $deviceCompliance = Get-DeviceManagementPolicy -authToken $authToken -managementType Compliance | Select-Object * -ExcludeProperty value
            foreach ($d in $deviceCompliance) {
                $d | Select-Object * -ExcludeProperty id, lastModifiedDateTime, roleScopeTagIds, supportsScopeTags, createdDateTime, version | ConvertTo-Json -Depth 100 | Out-File -FilePath "$compPath\$($d.displayName)`.json" -Encoding ascii -Force
            }
        }

        if ($ConfType -eq 'Script' -or $ConfType -eq 'All') {

            $scriptPath = "$FilePath\Intune-Plaster-Build\templates\scripts"

            if (Test-Path $scriptPath) {
                Write-Verbose "Exporting to $($scriptPath)"
            }
            else {
                Write-Verbose "Creating folder $($scriptPath)"
                try {
                    New-Item -Path $scriptPath -ItemType Directory -Force
                    Write-Verbose "Folder $($scriptPath) created"
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Unable to create folder" -ErrorAction Stop
                }
            }

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
