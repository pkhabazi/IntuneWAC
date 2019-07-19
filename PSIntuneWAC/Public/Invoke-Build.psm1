function Invoke-Build {
    <#
    .SYNOPSIS
    This function will

    #>
    [cmdletbinding()]
    param (
        [string]$configFile,
        [string]$outputPath,
        [string]$templatePath
    )

    try {
        $object = Get-Content $configFile | ConvertFrom-Json | Get-ObjectMembers
    }
    catch {
        Write-Verbose $_
        Write-Error "Unable to read Configuration from $($configFile)" -ErrorAction Stop
    }

    foreach ($item in $object) {
        $templateFilePath = "$templatePath\$($item.key).json"

        if (Test-Path $templateFilePath) {
            try {
                $templateFile = Get-Content -Raw $templateFilePath | ConvertFrom-Json
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to read json from $($templateFilePath)"
            }

            $objMembers = $item.Value | Get-ObjectMembers

            foreach ($obj in $objMembers) {
                Write-Output  "name is : $($obj.key) en value is $($obj.Value)"
                $templateFile.$($obj.Key) = $obj.Value
            }

            try {
                $templateFile | ConvertTo-Json | Out-File "$outputPath\$($item.Key).json" -Force
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable To save output"
            }
        }
        else {
            Write-Verbose "Template file not found: $($templateFilePath)"
            Write-Error "Template file not found" -ErrorAction Stop
        }
    }
}
