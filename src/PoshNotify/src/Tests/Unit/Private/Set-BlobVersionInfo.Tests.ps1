<#
ICloudBlob                         : Microsoft.Azure.Storage.Blob.CloudBlockBlob
BlobType                           : BlockBlob
Length                             : 736
IsDeleted                          : False
BlobClient                         : Azure.Storage.Blobs.BlobClient
BlobBaseClient                     : Azure.Storage.Blobs.Specialized.BlockBlobClient
BlobProperties                     : Azure.Storage.Blobs.Models.BlobProperties
RemainingDaysBeforePermanentDelete :
ContentType                        : application/octet-stream
LastModified                       : 05/20/21 02:06:54 +00:00
SnapshotTime                       :
ContinuationToken                  :
VersionId                          :
IsLatestVersion                    :
AccessTier                         : Hot
TagCount                           : 0
Tags                               :
Context                            : Microsoft.WindowsAzure.Commands.Storage.AzureStorageContex
                                     t
Name                               : test123
#>
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

    Context 'Set-BlobVersionInfo' {
        BeforeEach {
            $Blob = 'test'
            $file = 'c:\test.log'
            $context = [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext]::EmptyContextInstance
            $env:RESOURCE_GROUP = 'rgn'
            $env:STORAGE_ACCOUNT_NAME = 'san'
            $env:CONTAINER_NAME = 'xxxxxxxxxx/default/cn'

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
            Mock -CommandName Set-AzStorageBlobContent -MockWith {
                [PSCustomObject]@{
                    ICloudBlob                         = 'Microsoft.Azure.Storage.Blob.CloudBlockBlob'
                    BlobType                           = 'BlockBlob'
                    Length                             = '736'
                    IsDeleted                          = 'False'
                    BlobClient                         = 'Azure.Storage.Blobs.BlobClient'
                    BlobBaseClient                     = 'Azure.Storage.Blobs.Specialized.BlockBlobClient'
                    BlobProperties                     = 'Azure.Storage.Blobs.Models.BlobProperties'
                    RemainingDaysBeforePermanentDelete = ''
                    ContentType                        = 'application/octet-stream'
                    LastModified                       = '05/20/21 02:06:54 +00:00'
                    SnapshotTime                       = ''
                    ContinuationToken                  = ''
                    VersionId                          = ''
                    IsLatestVersion                    = ''
                    AccessTier                         = 'Hot'
                    TagCount                           = '0'
                    Tags                               = ''
                    Context                            = 'Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext'
                    Name                               = 'test123'
                }
            } #endMock
            Mock -CommandName Test-Path -MockWith {
                $true
            } #endMock
        } #beforeeach
        Context 'ShouldProcess' {
            BeforeEach {
                Mock -CommandName Set-BlobVersionInfo -MockWith { } #endMock
            }
            It 'Should process by default' {
                Set-BlobVersionInfo -Blob $Blob -File $file
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Set-BlobVersionInfo -Blob $Blob -File $file -Confirm }
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Set-BlobVersionInfo -Blob $Blob -File $file
                }
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Set-BlobVersionInfo -Blob $Blob -File $file -WhatIf }
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Set-BlobVersionInfo -Blob $Blob -File $file
                }
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Set-BlobVersionInfo -Blob $Blob -File $file -Force
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
            } #it
        } #context
        Context 'Error' {
            It 'should return false if an error is encountered uploading the blob' {
                Mock -CommandName Set-AzStorageBlobContent -MockWith {
                    throw 'FakeError'
                } #endMock
                Set-BlobVersionInfo -Blob $Blob -File $file -Force | Should -BeExactly $false
            } #it
            It 'should return false if no storage account info is returned' {
                Mock -CommandName Get-StorageInfo -MockWith {
                    $null
                } #endMock
                Set-BlobVersionInfo -Blob $Blob -File $file -Force | Should -BeExactly $false
            } #it
            It 'should return false if the file specified is not found' {
                Mock -CommandName Test-Path -MockWith {
                    $false1
                } #endMock
                Set-BlobVersionInfo -Blob $Blob -File $file -Force | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should return expected results if successful' {
                Set-BlobVersionInfo -Blob $Blob -File $file -Force | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
