function Invoke-Build {
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
        Invoke-Build -configFile .\settings.json -templatePath .\templates -outputPath .\output
    .Example
        Invoke-Build -configFile .\settings.json
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

    begin {
    }

    process {
        try {
            $object = Get-Content $ConfigFile | ConvertFrom-Json
        }
        catch {
            Write-Verbose $_
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
                New-Item $OutputPath -ItemType Directory -Force
            }
            catch {
                Write-Verbose $_
                Write-Error "Unable to create folder $($OutputPath)" -ErrorAction Stop
            }
        }

        $solutions = $object | Get-ObjectMember

        ## Exclude geenralsettings
        $solutions = $solutions | Where-Object { $_.key -notlike "generalSettings" }

        foreach ($solution in $solutions) {

            $items = $solution.Value | Get-ObjectMember

            $outputPathFull = "$OutputPath\$($solution.Key)"
            Write-Verbose "saving output to $outputPathFull"

            if (! (Test-Path $outputPathFull)) {
                try {
                    New-Item $outputPathFull -ItemType Directory -Force
                }
                catch {
                    Write-Verbose $_
                    Write-Error "Unable to create folder $($outputhPatFull)" -ErrorAction Stop
                }
            }

            <#
                if scripts then do something else
            #>
            if ($solution.key -eq 'scripts') {
                Write-Verbose "found some scripts"
            }
            else {
                foreach ($item in $items) {

                    $templateFilePath = "$TemplatePath\$($solution.Key)\$($item.key).json"
                    Write-Verbose "saving template to $templateFilePath"

                    if (Test-Path $templateFilePath) {
                        try {
                            $templateFile = Get-Content -Raw $templateFilePath | ConvertFrom-Json
                        }
                        catch {
                            Write-Verbose $_
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
            Write-Verbose ''
            Write-Verbose ''
        }
    }
}
