function Get-DeviceManagementPolicy {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER AuthToken
        Coming soon
    .PARAMETER ManagementType
        Coming soon
    .EXAMPLE
    Get-DeviceManagementPolicy -AuthToken $token -ManagementType Configuration
    .NOTES
    NAME: Get-DeviceManagementPolicy
    #>

    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Hashtable]$AuthToken,

        [Parameter(Mandatory)]
        [ValidateSet('Configuration', 'Compliance', 'Script')]
        [string]$ManagementType

    )

    begin {
        $precheckAuthToken = precheckAuthToken -Authtoken $AuthToken
        if ($precheckAuthToken) {
            Write-Verbose "Token renewd"
            $AuthToken = $precheckAuthToken
        }
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
        }

        Write-Verbose "Connecting to resource: $graphEndpoint"

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)"

        Write-Verbose "Connecting to uri: $($uri)"

        try {
            if ($managementType -eq "Script") {
                Write-Verbose "Getting Device Management Script"
                $response = @()
                $tmpRes = Invoke-RestMethod -Method Get -Uri $uri -Headers $AuthToken | select-object value -ExpandProperty value
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
                $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $AuthToken | select-object value -ExpandProperty value
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
            Write-Verbose $_.Exception
            Write-Error "Unable to get dat from graph" -ErrorAction Stop
        }
    }
}
