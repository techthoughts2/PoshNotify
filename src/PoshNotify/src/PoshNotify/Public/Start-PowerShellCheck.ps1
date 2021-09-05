<#
.SYNOPSIS
    Evaluates if new versions of PowerShell have been released and sends slack messages notifying of upgrades.
.DESCRIPTION
    Evaluates current version of PowerShell releases. Searches table if that version is already known. If not, the table will be updated and slack messages will be sent.
.EXAMPLE
    Start-PowerShellCheck

    Evalutes current PowerShell release information, updates table as required, sends slack messages as required.
.OUTPUTS
    None
.NOTES
    This took a lot longer to make than I thought it would.
.COMPONENT
    PoshNotify
#>
function Start-PowerShellCheck {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    param (
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

    } #begin
    Process {
        $result = $true #assume the best
        # -Confirm --> $ConfirmPreference = 'Low'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on

        $newVersionFound = $false
        $outTable = $false
        $outFile = $false

        $newPreviewVersionFound = $false
        $outPreviewTable = $false
        $outPreviewFile = $false

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'

            #region github release info

            # get the current release information
            $pwshReleaseInfo = Get-PowerShellReleaseInfo
            if ($null -eq $pwshReleaseInfo) {
                $result = $false
                return $result
            }

            #endregion

            #region table checks

            # query the table to see if the pwsh version already exists
            $partitionKey = $script:pwsh
            $rowKey = $pwshReleaseInfo.PwshVersion
            $getTableRowInfoSplat = @{
                PartitionKey = $partitionKey
                RowKey       = $rowKey
            }
            $pwshTableInfo = Get-TableRowInfo @getTableRowInfoSplat
            #--------------------------------------------------------
            $partitionKeyPreview = $script:pwshPreview
            $rowKeyPreview = $pwshReleaseInfo.PwshPreviewVersion
            $getTableRowInfoSplat = @{
                PartitionKey = $partitionKeyPreview
                RowKey       = $rowKeyPreview
            }
            $pwshPreviewTableInfo = Get-TableRowInfo @getTableRowInfoSplat
            #--------------------------------------------------------
            if ($pwshTableInfo -eq $false -or $pwshPreviewTableInfo -eq $false) {
                Write-Warning 'Tables could not be properly queried.'
                $result = $false
                return $result
            }
            #--------------------------------------------------------
            if ($null -eq $pwshTableInfo) {
                # the table entry has never been created
                Write-Verbose -Message 'PowerShell release version is newer'
                $newVersionFound = $true
                $outTable = $true
                $outFile = $true
            }
            else {
                Write-Verbose -Message 'Record was found. PowerShell Version already in table.'
            }
            #--------------------------------------------------------
            if ($null -eq $pwshPreviewTableInfo) {
                # the table entry has never been created
                Write-Verbose -Message 'PowerShell Preview release version is newer'
                $newPreviewVersionFound = $true
                $outPreviewTable = $true
                $outPreviewFile = $true
            }
            else {
                Write-Verbose -Message 'Record was found. PowerShell Preview Version already in table.'
            }

            #endregion

            #region PowerShell processing

            if ($outTable -eq $true) {
                Write-Verbose -Message 'New PowerShell version discovered. Adding row entry to table.'

                $properties = [ordered]@{
                    Title = $pwshReleaseInfo.PwshTitle
                    Link  = $pwshReleaseInfo.PwshLink
                }

                $setTableVersionInfoSplat = @{
                    PartitionKey = $partitionKey
                    RowKey       = $rowKey
                    Properties   = $properties
                }
                $tableStatus = Set-TableVersionInfo @setTableVersionInfoSplat

                if ($tableStatus -eq $false) {
                    $result = $false
                    return $result
                }
            }
            else {
                Write-Verbose -Message 'No new PowerShell version discovered. No table action taken.'
            }
            #--------------------------------------------------------
            if ($outFile -eq $true) {
                $blob = $script:pwsh
                Write-Verbose -Message 'New PowerShell version discovered. Updating version blob.'
                $pwshOnly = $pwshReleaseInfo | Select-Object PwshVersion, PwshTitle, PwshLink
                $psVersionXML = ConvertTo-Clixml -InputObject $pwshOnly -Depth 100
                $psVersionXML | Out-File -FilePath "$env:TEMP\$blob" -ErrorAction Stop

                $setBlobVersionSplat = @{
                    Blob  = $blob
                    File  = "$env:TEMP\$blob"
                    Force = $true
                }
                $blobStatus = Set-BlobVersionInfo @setBlobVersionSplat
                if ($blobStatus -eq $false) {
                    $result = $false
                    return $result
                }
            }
            else {
                Write-Verbose -Message 'No new PowerShell version discovered. No blob action taken.'
            }

            #endregion

            #region preview processing

            if ($outPreviewTable -eq $true) {
                Write-Verbose -Message 'New PowerShell preview version discovered. Adding row entry to table.'

                $properties = [ordered]@{
                    Title = $pwshReleaseInfo.PwshPreviewTitle
                    Link  = $pwshReleaseInfo.PwshPreviewLink
                    RC    = $pwshReleaseInfo.PwshPreviewRC
                }

                $setTablePreviewVersionInfoSplat = @{
                    PartitionKey = $partitionKeyPreview
                    RowKey       = $rowKeyPreview
                    Properties   = $properties
                }
                $tableStatus = Set-TableVersionInfo @setTablePreviewVersionInfoSplat

                if ($tableStatus -eq $false) {
                    $result = $false
                    return $result
                }
            }
            else {
                Write-Verbose -Message 'No new PowerShell preview version discovered. No table action taken.'
            }
            #--------------------------------------------------------
            if ($outPreviewFile -eq $true) {
                $blob = $script:pwshPreview
                Write-Verbose -Message 'New PowerShell preview version discovered. Updating version blob.'
                $pwshPreviewOnly = $pwshReleaseInfo | Select-Object PwshPreviewVersion, PwshPreviewTitle, PwshPreviewLink, PwshPreviewRC
                $psPreviewVersionXML = ConvertTo-Clixml -InputObject $pwshPreviewOnly -Depth 100
                $psPreviewVersionXML | Out-File -FilePath "$env:TEMP\$blob" -ErrorAction Stop

                $setBlobVersionSplat = @{
                    Blob  = $blob
                    File  = "$env:TEMP\$blob"
                    Force = $true
                }
                $blobStatus = Set-BlobVersionInfo @setBlobVersionSplat
                if ($blobStatus -eq $false) {
                    $result = $false
                    return $result
                }
            }
            else {
                Write-Verbose -Message 'No new PowerShell preview version discovered. No blob action taken.'
            }

            #endregion

            #region slack notifications

            Write-Verbose -Message 'Evaluating slack send requirements...'
            if ($newVersionFound -eq $true) {
                Write-Verbose -Message 'New pwsh slack message needs sent.'
                $slackSplat = @{
                    Text        = $pwshReleaseInfo.PwshTitle
                    Title       = 'New PowerShell Release'
                    Link        = $pwshReleaseInfo.PwshLink
                    MessageType = 'PowerShellVersion'
                }
                Send-SlackMessage @slackSplat
            }
            if ($newPreviewVersionFound -eq $true) {
                Write-Verbose -Message 'New preview slack message needs sent.'
                $slackSplatPreview = @{
                    Text        = $pwshReleaseInfo.PwshPreviewTitle
                    Title       = 'New PowerShell Preview Release'
                    Link        = $pwshReleaseInfo.PwshPreviewLink
                    MessageType = 'PowerShellVersion'
                }
                Send-SlackMessage @slackSplatPreview
            }

            #endregion

        } #if_Should
        return $result
    } #process
    End {
    } #end
} #Start-PowerShellCheck
