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
        Mock -CommandName Write-Warning

        It 'Should return $true when a object was found' {
            Get-ObjectMember -Obj $object | Should -BeTrue

            Assert-MockCalled -CommandName Write-Warning -Times 0 -Scope It
        }

        It 'Object count must be 2' {
            (Get-ObjectMember -Obj $object).count | Should -BeExactly 2

            Assert-MockCalled -CommandName Write-Warning -Times 0 -Scope It
        }
    }
}
