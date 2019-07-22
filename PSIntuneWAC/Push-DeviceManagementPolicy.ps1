Function Push-DeviceManagementPolicy {

    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        $json,

        [Parameter(Mandatory)]
        [ValidateSet('Configuration', 'Compliance', 'Script')]
        [string]$managementType
    )

    begin {
        precheckAuthToken
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
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($graphEndpoint)"

        try {
            Write-Verbose "Connecting to endpoint: $($graphEndpoint.Split('/')[1])"
            Write-Verbose "Connecting using fully uri: $($uri)"

            $res = Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $json -ContentType "application/json"
            return $res
        }
        catch {
            $ex = $_.Exception
            $errorResponse = $ex.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()

            Write-Verbose "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
            Write-Error "Response content:`n$responseBody" -ErrorAction Stop
        }
    }
}
