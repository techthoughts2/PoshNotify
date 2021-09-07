<#
.SYNOPSIS
    Evaluates if new versions of AZ PowerShell have been released and sends slack messages notifying of upgrades.
.DESCRIPTION
    Evaluates current version of AZ PowerShell releases. Searches table if that version is already known. If not, the table will be updated and slack messages will be sent.
.EXAMPLE
    Start-PowerShellAZCheck

    Evalutes current AZ PowerShell release information, updates table as required, sends slack messages as required.
.OUTPUTS
    None
.NOTES
    This took a lot longer to make than I thought it would.

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Start-PowerShellAZCheck {
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
            $azReleaseInfo = Get-PowerShellAZReleaseInfo
            if ($null -eq $azReleaseInfo) {
                $result = $false
                return $result
            }

            #endregion

            #region version

            #--------------------------------------------------------------------------------
            # query the table to see if the az version already exists
            $partitionKey = $script:az
            $rowKey = $azReleaseInfo.AZVersion
            $getTableRowInfoSplat = @{
                PartitionKey = $partitionKey
                RowKey       = $rowKey
            }
            $azTableInfo = Get-TableRowInfo @getTableRowInfoSplat
            #--------------------------------------------------------------------------------
            if ($azTableInfo -eq $false) {
                Write-Warning 'Table could not be properly queried for version.'
                $result = $false
                return $result
            }
            #--------------------------------------------------------------------------------
            if ($null -eq $azTableInfo) {
                # the table entry has never been created
                Write-Verbose -Message 'AZ release version is newer'
                $newVersionFound = $true
                $outTable = $true
                $outFile = $true
            }
            else {
                Write-Verbose -Message 'Record was found. AZ Version already in table.'
            }
            #--------------------------------------------------------------------------------
            if ($outTable -eq $true) {
                Write-Verbose -Message 'New az version discovered. Adding row entry to table.'

                $properties = [ordered]@{
                    Title = $azReleaseInfo.AZTitle
                    Link  = $azReleaseInfo.AZLink
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
                Write-Verbose -Message 'No new az version discovered. No table action taken.'
            }
            #--------------------------------------------------------------------------------
            if ($outFile -eq $true) {
                $blob = $script:az
                Write-Verbose -Message 'New az version discovered. Updating version blob.'
                $azOnly = $azReleaseInfo | Select-Object AZVersion, AZTitle, AzLink
                $psVersionXML = ConvertTo-Clixml -InputObject $azOnly -Depth 100
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
                Write-Verbose -Message 'No new az version discovered. No blob action taken.'
            }
            #--------------------------------------------------------------------------------
            Write-Verbose -Message 'Evaluating slack send requirements...'
            if ($newVersionFound -eq $true) {
                Write-Verbose -Message 'New az slack message needs sent.'
                $slackSplat = @{
                    Text        = $azReleaseInfo.AZTitle
                    Title       = 'New AZ PowerShell Release'
                    Link        = $azReleaseInfo.AZLink
                    MessageType = 'PowerShellVersion'
                }
                Send-SlackMessage @slackSplat | Out-Null
            }
            #--------------------------------------------------------------------------------

            #endregion

            #region preview version

            if ($null -ne $azReleaseInfo.AZPreviewVersion) {
                Write-Verbose -Message 'Preview version detected. Processing preview actions...'
                #--------------------------------------------------------------------------------
                # query the table to see if the az PREVIEW version already exists
                $partitionKeyPreview = $script:azPreview
                $rowKeyPreview = $azReleaseInfo.AZPreviewVersion
                $getPreviewTableRowInfoSplat = @{
                    PartitionKey = $partitionKeyPreview
                    RowKey       = $rowKeyPreview
                }
                $azPreviewTableInfo = Get-TableRowInfo @getPreviewTableRowInfoSplat
                #--------------------------------------------------------------------------------
                if ($azPreviewTableInfo -eq $false) {
                    Write-Warning 'Table could not be properly queried for preview version.'
                    $result = $false
                    return $result
                }
                #--------------------------------------------------------------------------------
                if ($null -eq $azPreviewTableInfo) {
                    # the table entry has never been created
                    Write-Verbose -Message 'AZ Preview release version is newer'
                    $newPreviewVersionFound = $true
                    $outPreviewTable = $true
                    $outPreviewFile = $true
                }
                else {
                    Write-Verbose -Message 'Record was found. AZ Preview Version already in table.'
                }
                #--------------------------------------------------------------------------------
                if ($outPreviewTable -eq $true) {
                    Write-Verbose -Message 'New az preview version discovered. Adding row entry to table.'

                    $properties = [ordered]@{
                        Title = $azReleaseInfo.AZPreviewTitle
                        Link  = $azReleaseInfo.AZPreviewLink
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
                    Write-Verbose -Message 'No new az preview version discovered. No table action taken.'
                }
                #--------------------------------------------------------------------------------
                if ($outPreviewFile -eq $true) {
                    $blob = $script:azPreview
                    Write-Verbose -Message 'New az preview version discovered. Updating version blob.'
                    $azPreviewOnly = $azReleaseInfo | Select-Object AZPreviewVersion, AZPreviewTitle, AZPreviewLink
                    $psVersionXML = ConvertTo-Clixml -InputObject $azPreviewOnly -Depth 100
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
                    Write-Verbose -Message 'No new az preview version discovered. No blob action taken.'
                }
                #--------------------------------------------------------------------------------
                Write-Verbose -Message 'Evaluating slack send requirements...'
                if ($newPreviewVersionFound -eq $true) {
                    Write-Verbose -Message 'New az preview slack message needs sent.'
                    $slackSplat = @{
                        Text        = $azReleaseInfo.AZPreviewTitle
                        Title       = 'New AZ Preview PowerShell Release'
                        Link        = $azReleaseInfo.AZPreviewLink
                        MessageType = 'PowerShellVersion'
                    }
                    Send-SlackMessage @slackSplat | Out-Null
                }
                #--------------------------------------------------------------------------------
            }
            else {
                Write-Verbose -Message 'No preview release was found. Skipping preview processing.'
            }

            #endregion

        } #if_Should
        return $result
    } #process
    End {
    } #end
} #Start-PowerShellAZCheck
