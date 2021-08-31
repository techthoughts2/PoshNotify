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
Import-Module 'Az.Storage'

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
    Context 'Get-StorageInfo' {
        BeforeEach {
            $context = [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext]::EmptyContextInstance
            $env:RESOURCE_GROUP = 'rgn'
            $env:STORAGE_ACCOUNT_NAME = 'san'
            $env:CONTAINER_NAME = 'xxxxxxxxxx/default/cn'

            Mock -CommandName Get-AzStorageAccount -MockWith {
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
        } #beforeeach
        Context 'Error' {
            It 'should return null if an error is encountered getting storage account context' {
                Mock -CommandName Get-AzStorageAccount -MockWith {
                    throw 'FakeError'
                } #endMock
                Get-StorageInfo | Should -BeNullOrEmpty
            } #it
            It 'should return null if no storage account info is returned' {
                Mock -CommandName Get-AzStorageAccount -MockWith {
                    $null
                } #endMock
                Get-StorageInfo | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should return expected results if successful' {
                $eval = Get-StorageInfo
                $eval.ResourceGroupName | Should -BeExactly 'rgn'
                $eval.StorageAccountName | Should -BeExactly 'san'
                $eval.Context | Should -BeOfType Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext
            } #it
        } #context-success
    } #context
} #inModule
