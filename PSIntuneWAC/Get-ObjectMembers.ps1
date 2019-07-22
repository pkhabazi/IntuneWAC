function Get-ObjectMembers {
    <#
    .SYNOPSIS
        coming soon
    .DESCRIPTION
        coming soon
    .PARAMETER Obj
        Coming soon
    .EXAMPLE
    Get-ObjectMembers -Obj
    .NOTES
    NAME: Get-ObjectMembers
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    Param(
        [Parameter(Mandatory, ValueFromPipeline = $true)]
        [PSCustomObject]$Obj
    )

    $Obj | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        [PSCustomObject]@{Key = $key; Value = $obj."$key" }
    }
}
