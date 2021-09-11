<#
.SYNOPSIS
    Retrieves specified blob and converts to PowerShell object
.DESCRIPTION
    Queries the storage container for the specified blob and downloads. It then converts the Clixml to PowerShell object.
.EXAMPLE
    Get-BlobVersionInfo -Blob 'sampledata'

    Preview      : 7.2.0
    PreviewRC    : 5
    PreviewTitle : v7.2.0-preview.5 Release of PowerShell
    PreviewLink  : https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.5
    Pwsh         : 7.1.3
    PwshTitle    : v7.1.3 Release of PowerShell
    PwshLink     : https://github.com/PowerShell/PowerShell/releases/tag/v7.1.3
.PARAMETER Blob
    Name of blob to retrieve
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Get-StorageInfo
    Get-AzStorageBlobContent
    Get-Content

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Get-BlobVersionInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Name of blob to retrieve')]
        [ValidateNotNullOrEmpty()]
        [string]$Blob
    )

    $result = $null

    $storageAcc = Get-StorageInfo

    $containerName = $env:CONTAINER_NAME.Split('/')[2]

    if ($null -eq $storageAcc.StorageAccountName) {
        # error logging has already occured in the sub function
        return $result
    }

    Write-Verbose -Message ('Retrieving blob data - {0} from {1}' -f $Blob, $containerName)
    $azBlobContentSplat = @{
        Context     = $storageAcc.Context
        Container   = $containerName
        Blob        = $Blob
        Destination = "$env:TEMP\$Blob"
        Confirm     = $false
        Force       = $true
        ErrorAction = 'Stop'
    }
    try {
        $blobRetrieve = Get-AzStorageBlobContent @azBlobContentSplat
        Write-Verbose -Message ('{0} retrieved successfully.' -f $blobRetrieve.Name)
    }
    catch [Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException] {
        $result = $false
        return $result
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage 'Get-BlobVersionInfo could not retrieve blob successfully.'
        return $result
    }

    Write-Verbose -Message 'Getting content of downloaded blob...'
    try {
        $blobInfo = Get-Content "$env:TEMP\$Blob" -Raw
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage 'Get-BlobVersionInfo encountered an error sourcing file info from disk.'
        return $result
    }

    Write-Verbose -Message 'Converting to PowerShell object...'
    $result = $blobInfo | ConvertFrom-Clixml

    return $result
} #Get-BlobVersionInfo
