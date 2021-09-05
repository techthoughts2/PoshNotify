<#
.SYNOPSIS
    Updates table in Azure function env parameter with provided info
.DESCRIPTION
    Updates table in Azure function env parameter with provided parition key, row key, and row properties
.EXAMPLE
    $setTableVersionInfoSplat = @{
        PartitionKey = $PartitionKey
        RowKey       = $RowKey
        Properties   = $Properties
    }

    Set-TableVersionInfo @setTableVersionInfoSplat

    Adds table row entry with provided info
.PARAMETER PartitionKey
    Table partition key
.PARAMETER RowKey
    Table row key
.PARAMETER Properties
    Row Properties and values
.PARAMETER Force
    Skip confirmation
.OUTPUTS
    System.Boolean
.NOTES
    Add-AzTableRow
.COMPONENT
    PoshNotify
#>
function Set-TableVersionInfo {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Table partition key')]
        [ValidateNotNullOrEmpty()]
        [string]$PartitionKey,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Table row key')]
        [ValidateNotNullOrEmpty()]
        [string]$RowKey,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Row Properties and values')]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Properties,
        [Parameter(Mandatory = $false,
            HelpMessage = 'Skip confirmation')]
        [switch]$Force
    )

    Begin {
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }

        Write-Verbose -Message ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)

        $result = $false #assume the worst

    }
    Process {
        # -Confirm --> $ConfirmPreference = 'Medium'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'

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

            Write-Verbose -Message ('Performing table update: {0} - {1} - {2}' -f $tableContext.Name, $PartitionKey, $RowKey)

            $addAzAzureTableRowSplat = @{
                table        = $tableContext.CloudTable
                partitionKey = $PartitionKey
                rowKey       = $RowKey
                property     = $Properties
            }

            try {
                Add-AzTableRow @addAzAzureTableRowSplat | Out-Null
                $result = $true
            }
            catch {
                Write-Error $_
                Send-TelegramError -ErrorMessage 'Set-TableVersionInfo an error was encountered writing to the table.'
                return $result
            }

        } #if_Should

    }

    End {
        if ($result -eq $true) {
            return $result
        }
    }

} #Set-TableVersionInfo
