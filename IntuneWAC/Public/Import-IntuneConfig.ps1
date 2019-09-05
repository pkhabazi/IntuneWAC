function Import-IntuneConfig {
    <#
    .SYNOPSIS
        some info

    .Description
        some info

    .Parameter azDevOps
        some info

    .Parameter SourceFilePath
        some info

    Import-IntuneConfig -azDevOps $false -SourceFilePath .\output\companyName

    .Example
    Import-IntuneConfig -azDevOps $false -SourceFilePath .\output\CondicioCloud
    #>

    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [bool]$AzDevOps,

        [Parameter(Mandatory)]
        [string]$SourceFilePath
    )

    begin {
        precheckAuthToken

        if ($SourceFilePath) { $SourceFilePath = $SourceFilePath.TrimEnd('\') } else { $SourceFilePath = $PSScriptRoot } # what to do with else, set default path of trow error?

        # does path need any test, because get-childitem is in try catch below?
        $deviceConfigurationPath = "$SourceFilePath\configurationPolicies"
        $deviceCompliancePath = "$SourceFilePath\compliancePolicies"
        $deviceScriptPath = "$SourceFilePath\scripts"
        $groupsPath = "$SourceFilePath\groups"
    }

    process {

        ## Try to get all json files, this files will be uploaded to graph
        try {
            $deviceConfiguration = Get-ChildItem $deviceConfigurationPath -ErrorAction SilentlyContinue
            $deviceCompliance = Get-ChildItem $deviceCompliancePath -ErrorAction SilentlyContinue
            $deviceScript = Get-ChildItem $deviceScriptPath -ErrorAction SilentlyContinue
            $groups = Get-ChildItem $groupsPath -ErrorAction SilentlyContinue
        }
        catch {
            Write-Verbose $_.Exception.Message
            Write-Error "Unable to get JSON files" -ErrorAction Stop
        }
        ## end of try

        ## Begin of Device configuration upload to intune graph
        Write-Output "Uploading Device configuration profiles to Intune.."
        if ($deviceConfiguration.count -ge 1) {
            foreach ($item in $deviceConfiguration) {
                $tmpJson = $null
                $tmpJson = Get-Content $item.FullName -raw

                if (Test-Json $tmpJson) {
                    Write-Verbose "Valid Json content in $($item.FullName)"
                    [psobject]$ReferenceTemplate = Get-DeviceManagementPolicy -ManagementType Configuration | Where-Object { $_.displayName -eq ((Get-Content $item.FullName | ConvertFrom-Json | Select-Object displayName).displayName) } | Select-Object * -ExcludeProperty id, lastModifiedDateTime, roleScopeTagIds, supportsScopeTags, createdDateTime, version, value

                    if ($ReferenceTemplate) {
                        Write-Output "Configuration profile with name $($ReferenceTemplate.displayName) already exists, comparing to find difference"
                        $comparePolicy = Compare-Policy -ReferenceTemplate $ReferenceTemplate -DifferenceTemplate $($tmpJson | ConvertFrom-Json)
                        if ($comparePolicy) {
                            Write-Verbose "Found Difference"
                            Write-Output ($comparePolicy | Format-Table | Out-String)

                            if ($PSCmdlet.ShouldProcess("Do you want to update profile: $($ReferenceTemplate.displayName)")) {
                                $result = Push-DeviceManagementPolicy -json $tmpJson -managementType Configuration
                            }
                            else {
                                Write-Output "No change have been made, deployment aborted"
                            }
                        }
                    }
                    else {
                        Write-Verbose "Configuration profile doesn't exists online"
                        $result = Push-DeviceManagementPolicy -json $tmpJson -managementType Configuration
                    }

                    if ($azDevOps) {
                        $result | ConvertTo-Yaml | Out-File -FilePath "$env:temp\Configuration_$($item.Name -replace '.json','').yaml" -Encoding ascii
                        $confLog = "$env:temp\Configuration_$($item.Name -replace '.json','').yaml"
                        Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Device Configuration Profile - $($item.Name -replace '.json','');]$confLog"
                    }
                }
                else {
                    Write-Error "JSON test filed for $($item.FullName)" -ErrorAction Stop
                }
            }
        }
        else {
            Write-Output "No Device configuration profiles found in $($deviceConfigurationPath) for upload"
        }
        ## End of Device configuration upload

        ## Begin of Device Compliance upload to intune graph
        Write-Output "Uploading Device compliance policies to Intune.."
        if ($deviceCompliance.count -ge 1) {
            foreach ($item in $deviceConfiguration) {
                $tmpJson = $null
                $tmpJson = Get-Content $item.FullName -raw

                if (Test-Json $tmpJson) {
                    Write-Verbose "Valid Json content in $($item.FullName)"
                    [psobject]$ReferenceTemplate = Get-DeviceManagementPolicy -ManagementType Compliance | Where-Object { $_.displayName -eq ((Get-Content $item.FullName | ConvertFrom-Json | Select-Object displayName).displayName) } | Select-Object * -ExcludeProperty id, lastModifiedDateTime, roleScopeTagIds, supportsScopeTags, createdDateTime, version, value

                    if ($ReferenceTemplate) {
                        Write-Output "Compliance profile with name $($ReferenceTemplate.displayName) already exists, comparing to find difference"
                        $comparePolicy = Compare-Policy -ReferenceTemplate $ReferenceTemplate -DifferenceTemplate $($tmpJson | ConvertFrom-Json)
                        if ($comparePolicy) {
                            Write-Verbose "Found Differences"
                            Write-Output ($comparePolicy | Format-Table | Out-String)

                            if ($PSCmdlet.ShouldProcess("Do you want to update profile: $($ReferenceTemplate.displayName)")) {
                                $result = Push-DeviceManagementPolicy -Json $tmpJson -managementType Compliance
                            }
                            else {
                                Write-Output "No change have been made, deployment aborted"
                            }
                        }
                    }
                    else {
                        Write-Verbose "Compliance profile doesn't exists online"
                        $result = Push-DeviceManagementPolicy -json $tmpJson -managementType Compliance
                    }

                    if ($azDevOps) {
                        $result | ConvertTo-Yaml | Out-File -FilePath "$env:temp\Configuration_$($item.Name -replace '.json','').yaml" -Encoding ascii
                        $confLog = "$env:temp\Configuration_$($item.Name -replace '.json','').yaml"
                        Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Device Configuration Profile - $($item.Name -replace '.json','');]$confLog"
                    }
                }
                else {
                    Write-Error "JSON test filed for $($item.FullName)" -ErrorAction Stop
                }
            }
        }
        else {
            Write-Output "No Device compliance policies found in $($deviceCompliancePath) for upload"
        }
        ## End of Device Compliance upload

        ## Begin of Scripts upload to intune graph
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
                $result = Push-DeviceManagementPolicy -json ($tmpJson | ConvertTo-Json -Depth 100) -managementType Script
                $result | ConvertTo-Yaml | Out-File -FilePath "$env:Temp\Script_$($x.Name -replace '.json','').yaml" -Encoding ascii -Force

                if ($azDevOps) {
                    $scriptLogName = $x.Name | Split-Path
                    Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Scripts - $($x.Name -replace '.json','');]$scriptLogName"
                }
            }
        }
        else {
            Write-Output "No scripts found in $($deviceScriptPath) for upload"
        }

        ## Begin of Groups creation to intune graph
        if ($groups.Count -ge 1) {
            foreach ($item in $groups) {
                $tmpJson = $null
                $tmpJson = Get-Content $item.FullName -Raw
                if (Test-Json $tmpJson) {
                    [psobject]$ReferenceTemplate = Get-DeviceManagementPolicy -ManagementType groups | Where-Object { $_.displayName -eq ((Get-Content $item.FullName | ConvertFrom-Json | Select-Object displayName).displayName) } | Select-Object *

                    if ($ReferenceTemplate.count -eq 1){
                        Write-Output "Group $($ReferenceTemplate.displayName) alreaddy exists!"
                        Write-Verbose ($ReferenceTemplate | Format-Table | Out-String)
                    }
                    elseif ($ReferenceTemplate.count -gt 2) {
                        Write-Error "Found $($ReferenceTemplate.count) groups with the same name, fix manuelly before running code" -ErrorAction Stop
                    }
                    else {
                        Write-Verbose "Group doesn't exists online, creating group..."
                        $result = Push-DeviceManagementPolicy -Json $tmpJson -managementType Group
                    }
                    if ($azDevOps) {
                        $compLog = "$env:temp\Compliance_$($x.Name -replace '.json','').yaml"
                        Write-Output "##vso[task.addattachment type=Distributedtask.Core.Summary;name=Device Compliance Policy - $($x.Name -replace '.json','');]$compLog"
                    }
                }
                else {
                    Write-Error "JSON test filed for $($item.FullName)"
                }
            }
        }
        else {
            Write-Verbose "No Grous profiles found in $($groupsPath) for upload"
        }
        ## End of Scripts upload
    }
}
