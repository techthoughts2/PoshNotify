<#
.SYNOPSIS
    Searches table in Azure function env parameter for unique entity using provided partition key and row key.
.DESCRIPTION
    Queries the table name specified by the Azure Function environment variable for a unique entity using the provided parition key and row key.
.EXAMPLE
    Get-TableRowInfo -PartitionKey 'pwsh' -RowKey '7.1.0'

    Retrieves entity data from table that matches provided parition and row key
.PARAMETER PartitionKey
    Table partition key
.PARAMETER RowKey
    Table row key
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Get-AzTableRow
.COMPONENT
    PoshNotify
#>
function Get-TableRowInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Table partition key')]
        [ValidateNotNullOrEmpty()]
        [string]$PartitionKey,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Table row key')]
        [ValidateNotNullOrEmpty()]
        [string]$RowKey
    )

    $result = $null

    $storageAcc = Get-StorageInfo

    if ($null -eq $storageAcc.StorageAccountName) {
        # error logging has already occured in the sub function
        return $result
    }

    $tableContext = Get-TableInfo -StorageContext $storageAcc

    if ($null -eq $tableContext) {
        # error logging has already occured in the sub function
        return $result
    }

    Write-Verbose -Message ('Searching for pKey: {0} rKey: {1} in {2} .' -f $PartitionKey, $RowKey, $tableContext.CloudTable)
    $getAzTableRowSplat = @{
        PartitionKey = $PartitionKey
        RowKey       = $RowKey
        Table        = $tableContext.CloudTable
        ErrorAction  = 'Stop'
    }
    try {
        $entity = Get-AzTableRow @getAzTableRowSplat
    }
    catch {
        $result = $false
        return $result
    }

    if ($null -eq $entity) {
        Write-Verbose -Message 'No match found based on provided criteria.'
    }
    else {
        $result = $entity
    }

    return $result

} #Get-TableRowInfo
