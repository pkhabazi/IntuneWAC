$modulePath = "$PSScriptRoot\..\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

InModuleScope $moduleName {
    $token = @{
        ExpiresOn     = "15 / 08 / 2019 17:25:53"
        TenantId      = "c8ce4011-e689 - 48a2-ba74-46fe334d73ff"
        refresh_token = "AQABAAAAAAAP0wLlqdLVToOpA4kwzSnxhY3JrShPv68guTTNLT32BhHmuQIUeJm1pWuTH3N1sPrNoZkOTaokoaRqXBPZx7gMhHT0wlEKJqV89olixElncUue_lXRL4rrDNlMhduvLvDqzoIXJ0wJOeRbHfGU3f…"
        ClientId      = "d1ddf0e4-d672 - 4dae-b554-9d5bdfd93547"
        Authorization = "Bearer eyJ0eXAiOiJKV1QiLCJub25jZSI6ImpsX3ZZMkFzcVl3X28xdHBKRnVXTDhpTDkyeF9nNFhnalV5cGh5VVBzTFEiLCJhbGciOiJSUzI1NiIsIng1dCI6ImllX3FXQ1hoWHh0MXpJRXN1NGM3YWNRVkd…"
        Content       = "application / json"
    }

    Describe 'Remove-Cache' {
        It 'Removes cached results from temp\cache.text' {
            Mock -CommandName Remove-Item -MockWith { }

            Remove-Cache

            Assert-MockCalled -CommandName Remove-Item -Times 1 -Exactly
        }
    }
}
