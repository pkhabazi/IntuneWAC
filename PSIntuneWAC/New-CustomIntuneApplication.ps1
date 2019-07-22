
function New-CustomIntuneApplication {
    <#
    .SYNOPSIS
    coming soon

    .description
    coming soon

    .EXAMPLE
    coming soon

    #>
    [CmdletBinding()]
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
