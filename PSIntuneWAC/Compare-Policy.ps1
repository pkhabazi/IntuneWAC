function Compare-Policy {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER DeviceManagementPolicy
        Coming soon
    .EXAMPLE
    Compare-Policy -DeviceManagementPolicy
    .NOTES
    NAME: Compare-Policy
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DeviceManagementPolicy
    )

    begin {

    }

    process {
        Write-Output "$DeviceManagementPolicy"
    }
}
