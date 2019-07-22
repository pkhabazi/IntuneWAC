@{
    RootModule        = 'PSIntuneWAC.psm1'
    ModuleVersion     = '0.0.1'
    GUID              = '1db89920-6552-4b78-9a59-04f477557bda'
    Author            = 'PKhabazi'
    CompanyName       = 'Condicio'
    Copyright         = '(c) 2019 Condicio. All rights reserved.'
    FunctionsToExport = @(
        'Invoke-Build'
        'Set-AdminConsent'
        'New-CustomIntuneApplication'
        'Import-IntuneConfig'
        'Export-IntuneConfig'
        'Get-AuthToken'
        'Export-IntuneConfig'
    )
}
