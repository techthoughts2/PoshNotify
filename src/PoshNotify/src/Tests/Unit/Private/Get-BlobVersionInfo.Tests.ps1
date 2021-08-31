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

    $context = [Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext]::EmptyContextInstance
    $env:RESOURCE_GROUP = 'rgn'
    $env:STORAGE_ACCOUNT_NAME = 'san'
    $env:CONTAINER_NAME = 'xxxxxxxxxx/default/cn'
    Context 'Get-BlobVersionInfo' {
        BeforeEach {
            $rawCliXML = @'
<Objs Version="1.1.0.1" xmlns="http://schemas.microsoft.com/powershell/2004/04">
    <Obj RefId="0">
        <TN RefId="0">
            <T>System.Management.Automation.PSCustomObject</T>
            <T>System.Object</T>
        </TN>
        <MS>
            <Version N="Preview">7.2.0</Version>
            <Version N="Pwsh">7.1.3</Version>
        </MS>
    </Obj>
</Objs>
'@
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
            Mock -CommandName Get-AzStorageBlobContent -MockWith {
                [PSCustomObject]@{
                    ICloudBlob                         = 'Microsoft.Azure.Storage.Blob.CloudBlockBlob'
                    BlobType                           = 'BlockBlob'
                    Length                             = '341'
                    IsDeleted                          = 'False'
                    BlobClient                         = 'Azure.Storage.Blobs.BlobClient'
                    BlobBaseClient                     = 'Azure.Storage.Blobs.Specialized.BlockBlobClient'
                    BlobProperties                     = 'Azure.Storage.Blobs.Models.BlobProperties'
                    RemainingDaysBeforePermanentDelete = ''
                    ContentType                        = 'application/octet-stream'
                    LastModified                       = '05/19/21 03:49:57 +00:00'
                    SnapshotTime                       = ''
                    ContinuationToken                  = ''
                    VersionId                          = ''
                    IsLatestVersion                    = ''
                    AccessTier                         = 'Unknown'
                    TagCount                           = '0'
                    Tags                               = ''
                    Context                            = 'Microsoft.WindowsAzure.Commands.Storage.AzureStorageContext'
                    Name                               = 'sampledata'
                }
            } #endMock
            Mock -CommandName Get-Content -MockWith {
                $rawCliXML
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if an error is encountered getting the blob' {
                Mock -CommandName Get-AzStorageBlobContent -MockWith {
                    throw 'FakeError'
                } #endMock
                Get-BlobVersionInfo -Blob 'sampledata' | Should -BeNullOrEmpty
            } #it
            It 'should return null if an error is encountered getting data from the file on the drive' {
                Mock -CommandName Get-Content -MockWith {
                    throw 'FakeError'
                } #endMock
                Get-BlobVersionInfo -Blob 'sampledata' | Should -BeNullOrEmpty
            } #it
            It 'should return null if no storage account info is returned' {
                Mock -CommandName Get-StorageInfo -MockWith {
                    $null
                } #endMock
                Get-BlobVersionInfo -Blob 'sampledata' | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should return expected results if successful' {
                $eval = Get-BlobVersionInfo -Blob 'sampledata'
                $eval.Preview.Major | Should -BeExactly 7
                $eval.Preview.Minor | Should -BeExactly 2
                # $eval.PreviewRC | Should -BeExactly 5
                $eval.Pwsh.Major | Should -BeExactly 7
                $eval.Pwsh.Minor | Should -BeExactly 1
            } #it
            It 'should return false if the blob is not found' {
                Mock -CommandName Get-AzStorageBlobContent -MockWith {
                    $ErrorCategory = 1
                    $ErrorMessage = "Can not find blob 'sampledatas' in container 'techthoughtscontainer', or the blob type is unsupported."
                    $Exception = New-Object -TypeName Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException -ArgumentList $ErrorMessage
                    Write-Error -Category $ErrorCategory -Message $ErrorMessage -Exception $Exception
                } #endMock
                Get-BlobVersionInfo -Blob 'sampledata' | Should -BeExactly $false
            } #it
        } #context-success
    } #context
} #inModule
