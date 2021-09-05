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
    function Send-TelegramError {
    }
    Context 'Get-TableInfo' {
        BeforeEach {
            $context = [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext]::EmptyContextInstance
            $env:TABLE_NAME = 'tableName'

            Mock -CommandName Get-AzStorageTable -MockWith {
                [PSCustomObject]@{
                    CloudTable = 'tableName'
                    Uri        = 'https://xxxxxxxxx.table.core.windows.net/tableName'
                    Context    = 'Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext'
                    Name       = 'tableName'
                }
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return false if an error is encountered getting storage account context' {
                Mock -CommandName Get-AzStorageTable -MockWith {
                    throw 'FakeError'
                } #endMock
                Get-TableInfo -StorageContext $context | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should return null if no table results are returned' {
                Mock -CommandName Get-AzStorageTable -MockWith {
                    $null
                } #endMock
                Get-TableInfo -StorageContext $context | Should -BeNullOrEmpty
            } #it
            It 'should return expected results if successful' {
                $eval = Get-TableInfo -StorageContext $context
                $eval.CloudTable | Should -BeExactly 'tableName'
                $eval.Name | Should -BeExactly 'tableName'
            } #it
        } #context-success
    } #context
} #inModule
