<#
.SYNOPSIS
    Evaluates if new versions of PSScriptAnalyzer have been released and sends slack messages notifying of upgrades.
.DESCRIPTION
    Evaluates current version of PSScriptAnalyzer releases. Searches table if that version is already known. If not, the table will be updated and slack messages will be sent.
.EXAMPLE
    Start-PSScriptAnalyzerCheck

    Evalutes current PSScriptAnalyzer release information, updates table as required, sends slack messages as required.
.OUTPUTS
    None
.NOTES
    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Start-PSScriptAnalyzerCheck {
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

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'

            #region github release info

            # get the current release information
            $pssaReleaseInfo = Get-PSScriptAnalyzerReleaseInfo
            if ($null -eq $pssaReleaseInfo) {
                $result = $false
                return $result
            }

            #endregion

            #region table checks

            # query the table to see if the version already exists
            $partitionKey = $script:pssa
            $rowKey = $pssaReleaseInfo.PSSAVersion
            $getTableRowInfoSplat = @{
                PartitionKey = $partitionKey
                RowKey       = $rowKey
            }
            $pssaTableInfo = Get-TableRowInfo @getTableRowInfoSplat
            #--------------------------------------------------------
            if ($pssaTableInfo -eq $false) {
                Write-Warning 'Table could not be properly queried.'
                $result = $false
                return $result
            }
            #--------------------------------------------------------
            if ($null -eq $pssaTableInfo) {
                # the table entry has never been created
                Write-Verbose -Message 'PSScriptAnalyzer release version is newer'
                $newVersionFound = $true
                $outTable = $true
                $outFile = $true
            }
            else {
                Write-Verbose -Message 'Record was found. PSScriptAnalyzer Version already in table.'
            }

            #endregion

            #region PSScriptAnalyzer processing

            if ($outTable -eq $true) {
                Write-Verbose -Message 'New PSScriptAnalyzer version discovered. Adding row entry to table.'

                $properties = [ordered]@{
                    Title = $pssaReleaseInfo.PSSATitle
                    Link  = $pssaReleaseInfo.PSSALink
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
                Write-Verbose -Message 'No new PSScriptAnalyzer version discovered. No table action taken.'
            }
            #--------------------------------------------------------
            if ($outFile -eq $true) {
                $blob = $script:pssa
                Write-Verbose -Message 'New PSScriptAnalyzer version discovered. Updating version blob.'
                # $pwshOnly = $pssaReleaseInfo | Select-Object PwshVersion, PwshTitle, PwshLink
                # $psVersionXML = ConvertTo-Clixml -InputObject $pwshOnly -Depth 100
                $psVersionXML = ConvertTo-Clixml -InputObject $pssaReleaseInfo -Depth 100
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
                Write-Verbose -Message 'No new PSScriptAnalyzer version discovered. No blob action taken.'
            }

            #endregion

            #region slack notifications

            Write-Verbose -Message 'Evaluating slack send requirements...'
            if ($newVersionFound -eq $true) {
                Write-Verbose -Message 'New PSScriptAnalyzer slack message needs sent.'
                $slackSplat = @{
                    Text        = $pssaReleaseInfo.PSSATitle
                    Title       = 'New PSScriptAnalyzer Release'
                    Link        = $pssaReleaseInfo.PSSALink
                    MessageType = 'PowerShellVersion'
                }
                Send-SlackMessage @slackSplat
            }

            #endregion

        } #if_Should
        return $result
    } #process
    End {
    } #end
} #Start-PSScriptAnalyzerCheck
