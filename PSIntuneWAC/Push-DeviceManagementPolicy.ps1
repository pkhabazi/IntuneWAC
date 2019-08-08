Function Push-DeviceManagementPolicy {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER Json
        COMING SOON
    .PARAMETER ManagementType
        COMING SOON
    .PARAMETER AuthToken
        Coming soon
    .EXAMPLE
    Push-DeviceManagementPolicy -Json -ManagementType Compliance -AuthToken $AuthToken
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
        [ValidateSet('Configuration', 'Compliance', 'Script', 'Groups')]
        [string]$ManagementType,

        [Parameter(Mandatory = $false)]
        [Hashtable]$AuthToken
    )

    begin {
        precheckAuthToken -authtoken $AuthToken
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
            "Groups" {
                $graphEndpoint = "groups"
                $graphApiVersion = "Beta"
            }
        }

        $uri = "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)"

        try {
            Write-Verbose "Connecting to endpoint: $($graphEndpoint.Split('/')[1])"
            Write-Verbose "Connecting using fully uri: $($uri)"

            $result = Invoke-RestMethod -Uri $uri -Headers $AuthToken -Method Post -Body $Json -ContentType "application/json"
            return $result
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
