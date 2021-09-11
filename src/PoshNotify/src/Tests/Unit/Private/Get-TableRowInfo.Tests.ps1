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
#-------------------------------------------------------------------------

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

    Context 'Get-TableRowInfo' {
        BeforeEach {
            $context = [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext]::EmptyContextInstance
            $env:RESOURCE_GROUP = 'rgn'
            $env:STORAGE_ACCOUNT_NAME = 'san'
            $env:CONTAINER_NAME = 'xxxxxxxxxx/default/cn'
            $env:TABLE_NAME = 'testtable'

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
            Mock -CommandName Get-AzTableRow -MockWith {
                [PSCustomObject]@{
                    Date           = '2021'
                    PartitionKey   = 'pwsh'
                    RowKey         = '7.1.0'
                    TableTimestamp = '08/28/21 22:55:26 -05:00'
                    Etag           = 'W/"datetime2021-08-29T03%3A55%3A26.2954648Z"'
                }
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if no storage account info is returned' {
                Mock -CommandName Get-StorageInfo -MockWith {
                    $null
                } #endMock
                Get-TableRowInfo -PartitionKey 'pkey' -RowKey 'rkey' | Should -BeNullOrEmpty
            } #it
            It 'should return null if no table results are returned' {
                Mock -CommandName Get-TableInfo -MockWith {
                    $null
                } #endMock
                Get-TableRowInfo -PartitionKey 'pkey' -RowKey 'rkey' | Should -BeNullOrEmpty
            } #it
            It 'should return false if an error is encountered getting table row info' {
                Mock -CommandName Get-AzTableRow -MockWith {
                    throw 'Fake Error'
                } #endMock
                Get-TableRowInfo -PartitionKey 'pkey' -RowKey 'rkey' | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should return expected results if successful' {
                $eval = Get-TableRowInfo -PartitionKey 'pkey' -RowKey 'rkey'
                $eval.PartitionKey | Should -BeExactly 'pwsh'
                $eval.RowKey | Should -BeExactly '7.1.0'
            } #it
            It 'should return null if the entity is not found' {
                Mock -CommandName Get-AzTableRow -MockWith {
                    $null
                } #endMock
                Get-TableRowInfo -PartitionKey 'pkey' -RowKey 'rkey' | Should -BeNullOrEmpty
            } #it
        } #context-success
    } #context
} #inModule
