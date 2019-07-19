function Import-IntuneConfig {

    [cmdletbinding()]
    param (
        [string]$yamlConfig,
        [switch]$azDevOps,
        [string]$sourceFilePath
    )

    begin {

        if ($sourceFilePath) { $sourceFilePath = $sourceFilePath.TrimEnd('\') } else { $sourceFilePath = $PSScriptRoot } # what to do with else, set default path of trow error?

        # does path need any test, because get-childitem is in try catch below?
        $deviceConfigurationPath = "$sourceFilePath\configuration"
        $deviceCompliancePath = "$sourceFilePath\compliance"
        $deviceScriptPath = "$sourceFilePath\$($config.client)\scripts"
    }

    process {

        ## Try to get all json files, this files will be uploaded to graph
        try {
            $deviceConfiguration = Get-ChildItem $deviceConfigurationPath
            $deviceCompliance = Get-ChildItem $deviceCompliancePath
            $deviceScript = Get-ChildItem $deviceScriptPath
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to get JSON files" -ErrorAction Stop
        }
        ## end of try


        ## Begin of Device configuration upload to intune graph
        Write-Verbose "Uploading Device configuration profiles to Intune.."
        if ($deviceConfiguration.count -ge 1) {
            foreach ($x in $deviceConfiguration) {
                $tmpJson = $null
                $tmpJson = Get-Content $x.FullName -raw
                $result = Push-DeviceManagementPolicy -authToken $authToken -json $tmpJson -managementType Configuration
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
        ## End of Device configuration upload


        ## Begin of Device Compliance upload to intune graph
        Write-Verbose "Uploading Device compliance policies to Intune.."
        if ($deviceCompliance.count -ge 1) {
            foreach ($x in (Get-ChildItem $deviceCompliance)) {
                $tmpJson = $null
                $tmpJson = Get-Content $x.FullName -raw
                $result = Push-DeviceManagementPolicy -authToken $authToken -json $tmpJson -managementType Compliance
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
        ## End of Device Compliance upload


        ## Begin of Scripts upload to intune graph
        Write-Verbose "Uploading scripts to Intune.."
        if ($deviceScript.count -ge 1) {
            foreach ($x in $deviceScriptPath) {
                $tmpJson = $null
                $tmpScript = $null
                $tmpEncScript = $null
                $tmpJson = Get-Content "$($x.FullName)\$($x.Name).json" -raw | ConvertFrom-Json
                $tmpScript = Get-Content "$($x.FullName)\$($x.Name).ps1" -raw
                $tmpEncScript = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$tmpScript"))
                $tmpJson | Add-Member -MemberType NoteProperty -Name "scriptContent" -Value $tmpEncScript
                $result = Push-DeviceManagementPolicy -authToken $authToken -json ($tmpJson | ConvertTo-Json -Depth 100) -managementType Script
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
        ## End of Scripts upload

    }
}
