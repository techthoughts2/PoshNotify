<#
.SYNOPSIS
    Gets the table context from the previously retrieved storage context and azure function parameter variables provided.
.DESCRIPTION
    Returns the table context based on the provided storage context and environment variables for table nane which are provided via the azure function parameters.
.EXAMPLE
    Get-TableInfo -StorageContext $storageContext

    Retrieves table information context
.PARAMETER StorageContext
    Azure Storage Account Object
.OUTPUTS
    Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageTable
.NOTES
    Get-AzStorageTable
.COMPONENT
    PoshNotify
#>
function Get-TableInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Azure Storage Account Object')]
        [ValidateNotNullOrEmpty()]
        $StorageContext
    )

    $storageTable = $null

    Write-Verbose -Message ('Retrieving table info for {0} in {1}' -f $env:TABLE_NAME, $env:STORAGE_ACCOUNT_NAME)

    $getAzStorageTableSplat = @{
        Name        = $env:TABLE_NAME
        Context     = $storageContext.Context
        ErrorAction = 'Stop'
    }
    try {
        $storageTable = Get-AzStorageTable @getAzStorageTableSplat
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage 'Get-StorageInfo did not find the storage account successfully.'
        return $storageTable
    }

    if ($null -eq $storageTable) {
        Write-Verbose -Message ('{0} not found' -f $env:TABLE_NAME)
        Send-TelegramError -ErrorMessage 'Get-AzStorageTable no table info was returned.'
        return $storageTable
    }

    return $storageTable
} #Get-TableInfo
