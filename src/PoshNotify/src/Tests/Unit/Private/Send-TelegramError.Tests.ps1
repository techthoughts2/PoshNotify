#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'PoshNotify'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
Import-Module 'Az.Storage' -Force

InModuleScope 'PoshNotify' {
    #-------------------------------------------------------------------------
    $WarningPreference = 'SilentlyContinue'
    #-------------------------------------------------------------------------
    BeforeAll {
        $WarningPreference = 'SilentlyContinue'
        $ErrorActionPreference = 'SilentlyContinue'
    }

    Context 'Send-TelegramError' {
        BeforeEach {
            function Send-TelegramTextMessage {
            }
            Mock -CommandName Send-TelegramTextMessage -MockWith {
                [PSCustomObject]@{
                    ok     = 'True'
                    result = '@{message_id=xxx; from=; chat=; date=xxxxxxxxx; text=test}'
                }
            } #endMock
        } #beforeeach
        Context 'Error' {
            # It 'should throw if an error is encountered' {
            #     Mock -CommandName Send-TelegramTextMessage -MockWith {
            #         throw 'FakeError'
            #     } #endMock
            #     { Send-TelegramError -ErrorMessage 'Error' } | Should Throw

            # } #it
        } #context-error
        Context 'Success' {
            It 'should not throw if successful' {
                { Send-TelegramError -ErrorMessage 'Error' } | Should -Not -Throw
            } #it
        } #context-success
    } #context
} #inModule
