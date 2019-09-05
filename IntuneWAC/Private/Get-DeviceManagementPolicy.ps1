function Get-DeviceManagementPolicy {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER ManagementType
        Coming soon
    .EXAMPLE
    Get-DeviceManagementPolicy -ManagementType Configuration
    .NOTES
    NAME: Get-DeviceManagementPolicy
    #>

    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Configuration', 'Compliance', 'Script', 'Groups')]
        [string]$ManagementType
    )

    begin {
        precheckAuthToken
    }

    process {
        switch ($ManagementType) {
            "Configuration" {
                $graphEndpoint = "deviceManagement/deviceConfigurations"
                $graphApiVersion = "Beta"
                break
            }
            "Compliance" {
                $graphEndpoint = "deviceManagement/deviceCompliancePolicies"
                $graphApiVersion = "Beta"
                break
            }
            "Script" {
                $graphEndpoint = "deviceManagement/deviceManagementScripts"
                $graphApiVersion = "Beta"
                break
            }
            "Groups" {
                $graphEndpoint = "groups"
                $graphApiVersion = "Beta"
            }
        }

        Write-Verbose "Connecting to resource: $graphEndpoint"

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)"

        Write-Verbose "Connecting to uri: $($uri)"

        try {
            if ($managementType -eq "Script") {
                Write-Verbose "Getting Device Management Script"
                $response = @()
                $tmpRes = Invoke-RestMethod -Method Get -Uri $uri -Headers $script:authToken | Select-Object value -ExpandProperty value
                if ($tmpRes) {
                    Write-Verbose "Found $($ManagementType)"
                    foreach ($x in $tmpRes) {
                        $response += Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)/$($x.id)" -Headers $script:authToken -ContentType "application/json"
                    }
                    return $response
                }
                else {
                    Write-Verbose "No Scripts found to return"
                }
            }
            else {
                Write-Verbose "Getting Device Management Configuration and/or Comliance Policy"
                $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $script:authToken | Select-Object value -ExpandProperty value
                if ($response) {
                    Write-Verbose "Found $($response.count) objects for $($ManagementType)"
                    return $response
                }
                else {
                    Write-Verbose "nothing to return"
                }
            }
        }
        catch {
            $ex = $_.Exception
            $errorResponse = $ex.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()

            Write-Verbose "Request to $uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
            Write-Error "Response content: ($responseBody)" -ErrorAction Stop
        }
    }
}
