function New-CustomIntuneApplication {
    <#
    .SYNOPSIS
    coming soon

    .description
    coming soon

    .EXAMPLE
    coming soon

    #>
    [cmdletbinding(SupportsShouldProcess=$true)]
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
