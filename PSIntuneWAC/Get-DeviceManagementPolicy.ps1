function Get-DeviceManagementPolicy {
    <#
    .SYNOPSIS
    .
    #>
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object.Hashtable]$authToken,

        [Parameter(Mandatory)]
        [ValidateSet('Configuration', 'Compliance', 'Script')]
        [string]$managementType

    )

    begin {
        precheckAuthToken -authtoken $authToken
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
