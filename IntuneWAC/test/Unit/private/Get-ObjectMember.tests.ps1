$modulePath = "$PSScriptRoot\..\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

InModuleScope $moduleName {
    $obj = @{
        'Object-01' = { @{
                name        = name;
                displayName = displayname;
                properties  = True;
            }
        }
        'Object-02' = { @{
                name        = name;
                displayName = displayname;
                properties  = True;
            }
        }
    }
    $object = New-Object psobject -Property $obj

    Describe Get-ObjectMember {
        It 'Should return $true when a object was found' {
            Get-ObjectMember -Obj $object | Should -BeTrue
        }

        It 'Object count must be 2' {
            (Get-ObjectMember -Obj $object).count | Should -BeExactly 2
        }
    }
}
