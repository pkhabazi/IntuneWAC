


class users {
    [ValidateSet("Included", "Excluded")]
    [string]$type

    [bool]$AllUsers

    [array]$Users

    [array]$Groups
    [array] $return
    users () {

    }

    users ($Type, $AllUsers) {
        if ($Type -eq "included") {
            if ($AllUsers) {
                $this.return = @{
                    "users"   = @{
                        "allUsers" = 1
                        "included" = @{
                            "groupIds" = @()
                            "userIds"  = @()
                        }
                        "excluded" = @{
                            "groupIds" = @()
                            "userIds"  = @()
                        }
                    }
                    "usersV2" = @{
                        "allUsers" = 1
                        "included" = @{
                            "allGuestUsers" = $false
                            "roles"         = $false
                            "userGroups"    = $false
                            "roleIds"       = @()
                            "groupIds"      = @()
                            "userIds"       = @()
                        }
                        "excluded" = @{
                            "allGuestUsers" = $false
                            "roles"         = $false
                            "userGroups"    = $false
                            "roleIds"       = @()
                            "groupIds"      = @()
                            "userIds"       = @()
                        }
                    }
                }
            }
            else {
                $this.return = @{
                    "users"   = @{
                        "allUsers" = 1
                        "included" = @{
                            "groupIds" = @()
                            "userIds"  = @()
                        }
                        "excluded" = @{
                            "groupIds" = @()
                            "userIds"  = @()
                        }
                    }
                    "usersV2" = @{
                        "allUsers" = 1
                        "included" = @{
                            "allGuestUsers" = $false
                            "roles"         = $false
                            "userGroups"    = $false
                            "roleIds"       = @()
                            "groupIds"      = @()
                            "userIds"       = @()
                        }
                        "excluded" = @{
                            "allGuestUsers" = $false
                            "roles"         = $false
                            "userGroups"    = $false
                            "roleIds"       = @()
                            "groupIds"      = @()
                            "userIds"       = @()
                        }
                    }
                }

            }
        }
    }
}

$users = [users]::new('Included', $true)
$users.type = 'Included'
$users.AllUsers = $true


class usersV2 {

}



class servicePrincipals {

}

class servicePrincipalsV2 {

}

class controls {
    [Parameter(Mandatory)]
    [bool]$controlsOr

    [Parameter(Mandatory)]
    [bool]$blockAccess

    [Parameter(Mandatory)]
    [bool]$challengeWithMfa

    [Parameter(Mandatory)]
    [bool]$compliantDevice

    [Parameter(Mandatory)]
    [bool]$domainJoinedDevice

    [Parameter(Mandatory)]
    [bool]$approvedClientApp

    [Parameter(Mandatory)]
    [array]$claimProviderControlIds

    [Parameter(Mandatory)]
    [bool]$requireCompliantApp

    [Parameter(Mandatory)]
    [bool]$requirePasswordChange

    [Parameter(Mandatory)]
    [int]$requiredFederatedAuthMethod

    controls () {

    }
}

$controls = [controls]::new()

class sessionControls {
    [Parameter(Mandatory)]
    [bool]$appEnforced

    [Parameter(Mandatory)]
    [bool]$cas

    [Parameter(Mandatory)]
    [ValidateSet("Monitor only", "Block downloads", "Use custom policy")]
    [string]$cloudAppSecuritySessionControlType

    [Parameter(Mandatory)]
    [object]$signInFrequencyTimeSpan

    [Parameter(Mandatory)]
    [int]$signInFrequency

    [Parameter(Mandatory)]
    [int]$persistentBrowserSessionMode

    sessionControls ($cloudAppSecuritySessionControlType) {
        switch ($cloudAppSecuritySessionControlType) {
            "Monitor only" {
                [int]$cloudAppSecuritySessionControlTypeResult = 0
            }
            "Block downloads" {
                [int]$cloudAppSecuritySessionControlTypeResult = 1
            }
            "Use custom policy" {
                Write-Warning "feature $($cloudAppSecuritySessionControlType) is currently not available" -WarningAction Stop
            }
        }
    }
}

class conditions {

}

class conditionalAccess {
    [Parameter(Mandatory)]
    [bool]$isAllProtocolsEnabled

    [Parameter(Mandatory)]
    [bool]$isUsersGroupsV2Enabled

    [Parameter(Mandatory)]
    [bool]$isCloudAppsV2Enabled

    [Parameter(Mandatory)]
    [guid]$policyId

    [Parameter(Mandatory)]
    [string]$policyName

    [Parameter(Mandatory)]
    [bool]$applyRule

    [Parameter(Mandatory)]
    [int]$policyState

    [Parameter(Mandatory)]
    [bool]$usePolicyState

    [Parameter(Mandatory)]
    [int]$baselineType

    [Parameter(Mandatory)]
    [System.Object]$Controls

    conditionalAccess () {

    }

    conditionalAccess ($isAllProtocolsEnabled, $isUsersGroupsV2Enabled, $isCloudAppsV2Enabled, $policyId, $policyName, $applyRule, $policyState, $usePolicyState, $baselineType, $Controls) {

    }

}

$conditionalAccess = [conditionalAccess]::new()
$conditionalAccess.Controls = $controls
