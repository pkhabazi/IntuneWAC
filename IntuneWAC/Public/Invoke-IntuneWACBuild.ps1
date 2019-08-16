function Invoke-IntuneWACBuild {
    <#
    .SYNOPSIS
        This function will generate the json file that wille be uploaded to the graph
    .DESCRIPTION
        This function is meant to generete the JSON files that will be uploaded to the graph
    .Parameter configfile
        Path to the config File
    .Parameter outputPath
        Path where the JSON files will be saced
    .Parameter templatePath
        Path to the JSON template files that will be used
    .Example
        Invoke-IntuneWACBuild -configFile .\examples\settings.json -templatePath .\examples\templates -OutputPath .\output -verbose
    .Example
        Invoke-IntuneWACBuild -ConfigFile ".\examples\settings.json" -templatePath ".\examples\templates" -OutputPath ".\output"
    #>


    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ConfigFile,

        [Parameter(Mandatory = $false)]
        [string]$OutputPath,

        [Parameter(Mandatory = $false)]
        [string]$TemplatePath
    )

    process {

        try {
            $object = (Get-Content $ConfigFile | ConvertFrom-Json)
        }
        catch {
            Write-Verbose $_.Exception.Message
            Write-Error "Unable to read Configuration from $($ConfigFile)" -ErrorAction Stop
        }

        if (! $TemplatePath) { $TemplatePath = ".\templates" } ## Chage path later


        if ($OutputPath) {
            $OutputPath = "$($OutputPath.TrimEnd('\'))\$($object.generalsettings.customerName)"
        }
        else {
            $OutputPath = "$($PSScriptRoot)\output\$($object.generalsettings.customerName)"
        }
        Write-Verbose "exporting alll setting to $OutputPath"

        if (! (Test-Path $OutputPath)) {
            try {
                $result = New-Item $OutputPath -ItemType Directory -Force
                Write-Verbose $result
            }
            catch {
                Write-Verbose $_.Exception.Message
                Write-Error "Unable to create folder $($OutputPath)" -ErrorAction Stop
            }
        }

        ## Begin of compliancePolicies
        if ($object.compliancePolicies) {

            $outputPathFull = "$OutputPath\compliancePolicies"
            Write-Verbose "Saving output to $outputPathFull"

            if (! (Test-Path $outputPathFull)) {
                try {
                    $result = New-Item $outputPathFull -ItemType Directory -Force
                    Write-Verbose $result
                }
                catch {
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable to create folder $($outputhPatFull)" -ErrorAction Stop
                }
            }

            $compliancePolicies = ($object.compliancePolicies | Get-ObjectMember)

            foreach ($item in $compliancePolicies) {

                $templateFilePath = "$TemplatePath\compliancePolicies\$($item.key).json"

                if (Test-Path $templateFilePath) {
                    try {
                        Write-Verbose "Importing template JSON from $templateFilePath"
                        $templateFile = Get-Content -Raw $templateFilePath | ConvertFrom-Json
                    }
                    catch {
                        Write-Verbose $_.Exception.Message
                        Write-Error "Unable to read json from $($templateFilePath)"
                    }

                    $objMembers = $item.Value | Get-ObjectMember

                    foreach ($obj in $objMembers) {
                        Write-Verbose "name is : $($obj.key) en value is $($obj.Value)"
                        $templateFile.$($obj.Key) = $obj.Value
                    }

                    try {
                        $templateFile | ConvertTo-Json | Out-File "$outputPathFull\$($item.Key).json" -Force
                    }
                    catch {
                        Write-Verbose $_.Exception.Message
                        Write-Error "Unable To save output"
                    }
                }
                else {
                    Write-Verbose "Template file not found: $($templateFilePath)"
                    Write-Error "Template file not found" -ErrorAction Stop
                }
            }
        }
        else {
            Write-Verbose "no compliancePolicies in Config file $ConfigFile"
        }
        ## End of compliancePolicies

        ## Begin of configurationPolicies
        if ($object.configurationPolicies) {

            $outputPathFull = "$OutputPath\configurationPolicies"
            Write-Verbose "Saving output to $outputPathFull"

            if (! (Test-Path $outputPathFull)) {
                try {
                    $result = New-Item $outputPathFull -ItemType Directory -Force
                    Write-Verbose $result
                }
                catch {
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable to create folder $($outputhPatFull)" -ErrorAction Stop
                }
            }

            $configurationPolicies = ($object.configurationPolicies | Get-ObjectMember)

            foreach ($item in $configurationPolicies) {

                $templateFilePath = "$TemplatePath\configurationPolicies\$($item.key).json"

                if (Test-Path $templateFilePath) {
                    try {
                        Write-Verbose "Importing template JSON from $templateFilePath"
                        $templateFile = Get-Content -Raw $templateFilePath | ConvertFrom-Json
                    }
                    catch {
                        Write-Verbose $_.Exception.Message
                        Write-Error "Unable to read json from $($templateFilePath)"
                    }

                    $objMembers = $item.Value | Get-ObjectMember

                    foreach ($obj in $objMembers) {
                        Write-Verbose  "name is : $($obj.key) en value is $($obj.Value)"
                        $templateFile.$($obj.Key) = $obj.Value
                    }

                    try {
                        $templateFile | ConvertTo-Json | Out-File "$outputPathFull\$($item.Key).json" -Force
                    }
                    catch {
                        Write-Verbose $_.Exception.Message
                        Write-Error "Unable To save output"
                    }
                }
                else {
                    Write-Verbose "Template file not found: $($templateFilePath)"
                    Write-Error "Template file not found" -ErrorAction Stop
                }
            }
        }
        else {
            Write-Verbose "no configurationPolicies in Config file $ConfigFile"
        }
        ## End of configurationPolicies

        ## Begin of scripts
        if ($object.scripts) {

            $outputPathFull = "$OutputPath\scripts"
            Write-Verbose "Saving output to $outputPathFull"

            if (! (Test-Path $outputPathFull)) {
                try {
                    $result = New-Item $outputPathFull -ItemType Directory -Force
                    Write-Verbose $result
                }
                catch {
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable to create folder $($outputhPatFull)" -ErrorAction Stop
                }
            }
            #$scripts = ($object.scripts | Get-ObjectMember)
            #return $scripts
        }
        else {
            Write-Verbose "no scripts in Config file $ConfigFile"
        }
        ## End of scripts

        ## Begin of Groups
        if ($object.groups) {

            $outputPathFull = "$OutputPath\groups"
            Write-Verbose "Saving output to $outputPathFull"

            if (! (Test-Path $outputPathFull)) {
                try {
                    $result = New-Item $outputPathFull -ItemType Directory -Force
                    Write-Verbose $result
                }
                catch {
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable to create folder $($outputhPatFull)" -ErrorAction Stop
                }
            }

            foreach ($item in $object.groups) {
                $dynamicGroup = @{
                    description                   = $item.description
                    displayName                   = $item.displayName
                    groupTypes                    = @(
                        'DynamicMembership'
                    )
                    mailEnabled                   = $false
                    mailNickname                  = $item.displayName
                    securityEnabled               = $true
                    membershipRule                = $item.membershipRule
                    membershipRuleProcessingState = 'on'
                }

                try {
                    $dynamicGroup | ConvertTo-Json | Out-File "$outputPathFull\$($item.displayName).json" -Force
                }
                catch {
                    Write-Verbose $_.Exception.Message
                    Write-Error "Unable To save output"
                }
            }
        }
        else {
            Write-Verbose "No groups found in Config file: $ConfigFile"
        }
        ## Endof groups
    }
}
