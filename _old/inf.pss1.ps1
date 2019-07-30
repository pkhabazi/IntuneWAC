$username = "pouyan.graph@condiciocloud.onmicrosoft.com"
$pass = "Ehk58HV^3ab@lsp3" | ConvertTo-SecureString -AsPlainText -Force

Get-DeviceManagementPolicy -managementType Compliance -username $username -password $pass
Get-DeviceManagementPolicy -managementType Compliance -authToken $authToken

#region Unattended Authentication
$global:authToken = Get-AuthToken -User $username -Pass $password

#endregion
