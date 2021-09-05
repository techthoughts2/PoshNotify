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

    Context 'Set-TableVersionInfo' {
        BeforeEach {
            $context = [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext]::EmptyContextInstance
            $env:RESOURCE_GROUP = 'rgn'
            $env:STORAGE_ACCOUNT_NAME = 'san'
            $env:CONTAINER_NAME = 'xxxxxxxxxx/default/cn'
            $env:TABLE_NAME = 'testtable'
            $Properties = [ordered]@{
                Date = '2022'
            }
            Mock -CommandName Get-StorageInfo -MockWith {
                [PSCustomObject]@{
                    ResourceGroupName           = 'rgn'
                    StorageAccountName          = 'san'
                    Id                          = '/subscriptions/xxxx-xxxx/resourceGroups/rgn/providers/Microsoft.Storage/storageAccounts/san'
                    Location                    = 'westus'
                    Sku                         = 'Microsoft.Azure.Commands.Management.Storage.Models.PSSku'
                    Kind                        = 'StorageV2'
                    Encryption                  = 'Microsoft.Azure.Management.Storage.Models.Encryption'
                    AccessTier                  = 'Hot'
                    CreationTime                = '08/09/20 04:43:58'
                    CustomDomain                = ''
                    Identity                    = ''
                    LastGeoFailoverTime         = ''
                    PrimaryEndpoints            = 'Microsoft.Azure.Management.Storage.Models.Endpoints'
                    PrimaryLocation             = 'westus'
                    ProvisioningState           = 'Succeeded'
                    SecondaryEndpoints          = ''
                    SecondaryLocation           = ''
                    StatusOfPrimary             = 'Available'
                    StatusOfSecondary           = ''
                    Tags                        = '{}'
                    EnableHttpsTrafficOnly      = 'True'
                    AzureFilesIdentityBasedAuth = ''
                    EnableHierarchicalNamespace = ''
                    FailoverInProgress          = ''
                    LargeFileSharesState        = ''
                    NetworkRuleSet              = ''
                    RoutingPreference           = ''
                    BlobRestoreStatus           = ''
                    GeoReplicationStats         = ''
                    AllowBlobPublicAccess       = ''
                    MinimumTlsVersion           = ''
                    EnableNfsV3                 = ''
                    AllowSharedKeyAccess        = ''
                    Context                     = $context
                    ExtendedProperties          = '{}'
                }
            } #endMock
            Mock -CommandName Get-TableInfo -MockWith {
                [PSCustomObject]@{
                    CloudTable = 'tableName'
                    Uri        = 'https://xxxxxxxxx.table.core.windows.net/tableName'
                    Context    = 'Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext'
                    Name       = 'tableName'
                }
            } #endMock
            Mock -CommandName Add-AzTableRow -MockWith {
                [PSCustomObject]@{
                    Result         = 'Microsoft.Azure.Cosmos.Table.DynamicTableEntity'
                    HttpStatusCode = '204'
                    Etag           = 'W/"datetime2021-09-02T21%3A31%3A43.0434715Z"'
                    SessionToken   = ''
                    RequestCharge  = ''
                    ActivityId     = ''
                }
            } #endMock
        } #beforeeach
        Context 'ShouldProcess' {
            BeforeEach {
                Mock -CommandName Set-TableVersionInfo -MockWith { } #endMock
            }
            It 'Should process by default' {
                Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties }
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties
                }
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties -WhatIf }
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties
                }
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties -Force
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 1
            } #it
        } #context
        Context 'Error' {
            It 'should return false if an error is encountered updating the table' {
                Mock -CommandName Add-AzTableRow -MockWith {
                    throw 'FakeError'
                } #endMock
                Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties -Force | Should -BeExactly $false
            } #it
            It 'should return false if no storage account info is returned' {
                Mock -CommandName Get-StorageInfo -MockWith {
                    $null
                } #endMock
                Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties | Should -BeExactly $false
            } #it
            It 'should return false if no table results are returned' {
                Mock -CommandName Get-TableInfo -MockWith {
                    $null
                } #endMock
                Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should return expected results if successful' {
                Set-TableVersionInfo -PartitionKey 'pwsh' -RowKey '8.0.0' -Properties $Properties -Force | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
