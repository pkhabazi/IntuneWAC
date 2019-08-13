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
    .Parameter authToken
    coming soon
    .EXAMPLE
    Export-IntuneConfig -ConfType All -AuthToken $token -FilePath "C:\sources\pkm-intune\demo" -Verbose
    Export Current configuration to spicified folder
    .EXAMPLE
    Export-IntuneConfig -ConfType All -AuthToken $token -FilePath "C:\sources\pkm-intune\demo"
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

        [Parameter(Mandatory)]
        [Hashtable]$AuthToken
    )

    process {

        if ($FilePath) { $FilePath = $FilePath.TrimEnd('\') } else { $FilePath = $PSScriptRoot } # what to do with else, set default path of trow error?

        if (Test-Path $FilePath) {
            Write-Verbose "Exporting files to $($FilePath)"
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

        if ($ConfType -eq 'Configuration' -or $ConfType -eq 'All') {

            $configPath = "$FilePath\config-profiles"

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

            $deviceConfiguration = Get-DeviceManagementPolicy -AuthToken $AuthToken -managementType Configuration -Verbose | Select-Object * -ExcludeProperty value
            foreach ($d in $deviceConfiguration) {
                $d | Select-Object * -ExcludeProperty id, lastModifiedDateTime, roleScopeTagIds, supportsScopeTags, createdDateTime, version | ConvertTo-Json -Depth 100 | Out-File -FilePath "$configPath\$($d.displayName)`.json" -Encoding ascii -Force
            }
        }

        if ($ConfType -eq 'Compliance' -or $ConfType -eq 'All') {

            $compPath = "$FilePath\compliance-policies"

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

            $deviceCompliance = Get-DeviceManagementPolicy -AuthToken $AuthToken -managementType Compliance | Select-Object * -ExcludeProperty value
            foreach ($d in $deviceCompliance) {
                $d | Select-Object * -ExcludeProperty id, lastModifiedDateTime, roleScopeTagIds, supportsScopeTags, createdDateTime, version | ConvertTo-Json -Depth 100 | Out-File -FilePath "$compPath\$($d.displayName)`.json" -Encoding ascii -Force
            }
        }

        if ($ConfType -eq 'Script' -or $ConfType -eq 'All') {

            $scriptPath = "$FilePath\scripts"

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

            $scripts = Get-DeviceManagementPolicy -AuthToken $AuthToken -managementType Script | Select-Object * -ExcludeProperty value
            foreach ($d in $scripts) {
                $tmpJson = $d | select-object '@odata.context', displayName, description, runAsAccount, enforceSignatureCheck, fileName, runAs32Bit;
                New-Item "$scriptPath\$($d.DisplayName)" -ItemType Directory -Force | Out-Null;
                $tmpJson | ConvertTo-Json -Depth 100 | Out-File -FilePath "$scriptPath\$($d.displayName)\$($d.displayName)`.json" -Encoding ascii -Force;
                [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String("$($d.scriptContent)")) | Out-File -FilePath "$scriptPath\$($d.displayName)\$($d.displayName)`.ps1" -Encoding ascii -Force;
            }
        }
    }
}
