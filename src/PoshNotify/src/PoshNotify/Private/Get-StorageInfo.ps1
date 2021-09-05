<#
.SYNOPSIS
    Gets the storage account context from the azure function parameter variables provided.
.DESCRIPTION
    Returns the storage account context based on the environment variables for storage account info which are provided via the azure function parameters.
.EXAMPLE
    Get-StorageInfo

    Retrieves storage account information for SA declared in environment variables
.OUTPUTS
    Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount
.NOTES
    Get-AzStorageAccount

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Get-StorageInfo {
    [CmdletBinding()]
    param (
    )

    $storageAcc = $null

    Write-Verbose -Message ('Retrieving storage account info for {0} in {1}' -f $env:STORAGE_ACCOUNT_NAME, $env:RESOURCE_GROUP)
    $azStorageAccountSplat = @{
        ResourceGroupName = $env:RESOURCE_GROUP
        Name              = $env:STORAGE_ACCOUNT_NAME
        ErrorAction       = 'Stop'
    }
    try {
        $storageAcc = Get-AzStorageAccount @azStorageAccountSplat
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage 'Get-StorageInfo did not find the storage account successfully.'
        return $storageAcc
    }

    if ($null -eq $storageAcc) {
        Write-Verbose -Message 'No storage account found.'
        Send-TelegramError -ErrorMessage 'Get-StorageInfo no storage account info was returned.'
        return $storageAcc
    }

    return $storageAcc
} #Get-StorageInfo
