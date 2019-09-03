function New-CustomIntuneApplication {
    <#
    .SYNOPSIS
    coming soon

    .description
    coming soon

    .parameter UserName
    coming
    .parameter ApplicationName
    coming

    .EXAMPLE
    New-CustomIntuneApplication -UserName -ApplicationName

    #>
    [cmdletbinding(SupportsShouldProcess = $true)]
    param (
        # Parameter help description
        [Parameter(mandatory = $true)]
        [string]$UserName,

        # Parameter help description
        [Parameter(mandatory = $true)]
        [string]$ApplicationName
    )

    begin {

    }

    process {
        Write-Output "$UserName and $ApplicationName"
        New-Item $UserName -WhatIf
    }
}
