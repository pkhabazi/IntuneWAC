function Push-DeviceManagementPolicy {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER Json
        COMING SOON
    .PARAMETER ManagementType
        COMING SOON
    .EXAMPLE
    Push-DeviceManagementPolicy -Json -ManagementType Compliance
    Authenticates you with the Graph API interface
    .NOTES
    NAME: Push-DeviceManagementPolicy
    #>

    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$Json,

        [Parameter(Mandatory)]
        [ValidateSet('Configuration', 'Compliance', 'Script', 'Group')]
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
            }
            "Compliance" {
                $graphEndpoint = "deviceManagement/deviceCompliancePolicies"
                $graphApiVersion = "Beta"
            }
            "Script" {
                $graphEndpoint = "deviceManagement/deviceManagementScripts"
                $graphApiVersion = "Beta"
            }
            "Group" {
                $graphEndpoint = "groups"
                $graphApiVersion = "Beta"
            }
        }

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)"

        try {
            Write-Verbose "Connecting to endpoint: $($graphEndpoint.Split('/')[1])"
            Write-Verbose "Connecting using fully uri: $($uri)"

            $result = Invoke-RestMethod -Uri $uri -Headers $script:authToken -Method Post -Body $Json -ContentType "application/json"
            return $result
        }
        catch {
            $ex = $_.Exception
            Write-Verbose "Request to $uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
            Write-Error "Response content: ()" -ErrorAction Stop
        }
    }
}
