function Compare-ObjectProperties {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER ReferenceTemplate
        Coming soon
    .PARAMETER DifferenceTemplate
    Coming soon
    .EXAMPLE
    Compare-ObjectProperties -ReferenceTemplate .\template.json -DifferenceTemplate .\template2.jos

    .NOTES
    NAME: Compare-ObjectProperties
    #>

    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$ReferenceTemplate,

        # Parameter help description
        [Parameter(Mandatory)]
        [string]$DifferenceTemplate
    )

    process {

        try {
            $DifferenceObject = (Get-Content $DifferenceTemplate | ConvertFrom-Json)
        }
        catch {
            Write-Error $_ -ErrorAction Stop
        }

        try {
            $ReferenceObject = (Get-Content $ReferenceTemplate | ConvertFrom-Json)
        }
        catch {
            Write-Error $_
        }

        $objprops = $ReferenceObject | Get-Member -MemberType Property, NoteProperty | % Name
        $objprops += $DifferenceObject | Get-Member -MemberType Property, NoteProperty | % Name
        $objprops = $objprops | Sort | Select -Unique

        $diffs = @()

        foreach ($objprop in $objprops) {
            $diff = Compare-Object $ReferenceObject $DifferenceObject -Property $objprop
            if ($diff) {
                $diffprops = @{
                    PropertyName = $objprop
                    RefValue     = ($diff | ? { $_.SideIndicator -eq '<=' } | % $($objprop))
                    DiffValue    = ($diff | ? { $_.SideIndicator -eq '=>' } | % $($objprop))
                }
                $diffs += New-Object PSObject -Property $diffprops
            }
        }
        if ($diffs) { return ($diffs | Select PropertyName, RefValue, DiffValue) }
    }
}
