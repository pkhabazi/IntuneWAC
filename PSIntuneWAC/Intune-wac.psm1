$clientId = "514e80b8-f8eb-4dbf-a11e-3d680716473b"
$tenantId = "c8ce4011-e689-48a2-ba74-46fe334d73ff"
$clientSecret = 'emH.yXnv/Z-EhRe[PnmAjLBxBs53dS31'

$token = Get-AuthToken -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -Authtype Application
$tokenuser = Get-AuthToken -userName "pouyan.graph@condiciocloud.onmicrosoft.com" -password "Ehk58HV^3ab@lsp3" -tenantId $tenantId -Authtype User -Verbose

precheckAuthToken -authtoken $authToken -Verbose
