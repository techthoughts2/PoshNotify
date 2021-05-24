<#
.SYNOPSIS
    Updates blob with current PowerShell version information
.DESCRIPTION
    Updates blob with current PowerShell version information stored in Cli-XML format.
.EXAMPLE
    $setBlobVersionSplat = @{
        Blob  = $script:psVersionData
        File  = "$env:TEMP\$script:psVersionData"
        Force = $true
    }
    Set-BlobVersionInfo @setBlobVersionSplat

    Creates blob with current PowerShell version information.
.PARAMETER Blob
    Name of blob to save
.PARAMETER File
    Full file path to upload
.PARAMETER Force
    Skip confirmation
.OUTPUTS

.NOTES
    Set-AzStorageBlobContent
    Test-Path
.COMPONENT
    PoshNotify
#>
function Set-BlobVersionInfo {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Name of blob to save')]
        [ValidateNotNullOrEmpty()]
        [string]$Blob,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Full file path to upload')]
        [ValidateNotNullOrEmpty()]
        [string]$File,
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

        $containerName = $env:CONTAINER_NAME.Split('/')[2]
    }
    Process {
        # -Confirm --> $ConfirmPreference = 'Medium'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'

            $storageAcc = Get-StorageInfo

            if ($null -eq $storageAcc) {
                # error logging has already occured in the sub function
                return $result
            }

            Write-Verbose -Message ('Confirming {0} exists' -f $File)
            if (-not(Test-Path $file)) {
                Write-Warning -Message ('{0} was not found.' -f $file)
                Send-TelegramError -ErrorMessage '\\\ Project PoshNotify - Set-BlobVersionInfo the file was not found.'
                return $result
            }
            else {
                Write-Verbose -Message 'CONFIRMED'
            }

            Write-Verbose -Message ('Uploading {0} to {1}' -f $Blob, $containerName)
            $azureBlobSplat = @{
                File        = $File
                Container   = $containerName
                Blob        = $Blob
                Contex      = $storageAcc.Context
                Confirm     = $false
                Force       = $true
                ErrorAction = 'Stop'
            }
            try {
                Set-AzStorageBlobContent @azureBlobSplat | Out-Null
                $result = $true
            }
            catch {
                Write-Error $_
                Send-TelegramError -ErrorMessage '\\\ Project PoshNotify - Set-BlobVersionInfo an error was encountered uploading the blob.'
                return $result
            }

        }#if_Should

    }

    End {
        if ($result -eq $true) {
            return $result
        }
    }

} #Set-BlobVersionInfo
