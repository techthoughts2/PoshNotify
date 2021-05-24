<#
.SYNOPSIS
    Evaluates if new versions of AZ PowerShell have been released and sends slack messages notifying of upgrades.
.DESCRIPTION
    Evaluates current version of AZ PowerShell releases. If a version blob is not found, one will be populated. The version blob will be evaluated against release information to determine if a new version is available. If it is, the blob will be updated and slack messages will be sent.
.EXAMPLE
    Start-PowerShellAZCheck

    Evalutes current AZ PowerShell release information, updates version blob as required, sends slack messages as required.
.OUTPUTS
    None
.NOTES
    This took a lot longer to make than I thought it would.
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

    }#begin
    Process {
        $result = $true #assume the best
        # -Confirm --> $ConfirmPreference = 'Low'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on

        $newVersionFound = $false
        $outFile = $false

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'

            #--------------------------------------------------------
            # get the current release information
            $azReleaseInfo = Get-PowerShellAZReleaseInfo
            if ($null -eq $azReleaseInfo) {
                $result = $false
                return $result
            }
            #--------------------------------------------------------
            # get the az version info from the blob for comparison
            $azBlobVersionInfo = Get-BlobVersionInfo -Blob $script:azVersionDate
            switch ($azBlobVersionInfo) {
                $false {
                    # the blob has never been created
                    $outFile = $true
                }
                $null {
                    # error was encountered
                    Write-Verbose -Message 'Unable to determine version change. No action taken.'
                    $result = $false
                    return $result
                }
                Default {
                    if ([version]$azReleaseInfo.AZVersion -gt [version]$azBlobVersionInfo.AZVersion) {
                        Write-Verbose -Message 'AZ release version is newer'
                        $newVersionFound = $true
                        $outFile = $true
                    }
                }
            }
            #--------------------------------------------------------
            if ($outFile -eq $true) {
                Write-Verbose -Message 'New version discovered. Updating version blob.'
                $psVersionXML = ConvertTo-Clixml -InputObject $azReleaseInfo -Depth 100
                $psVersionXML | Out-File -FilePath "$env:TEMP\$script:azVersionDate" -ErrorAction Stop

                $setBlobVersionSplat = @{
                    Blob  = $script:azVersionDate
                    File  = "$env:TEMP\$script:azVersionDate"
                    Force = $true
                }
                $blobStatus = Set-BlobVersionInfo @setBlobVersionSplat
                if ($blobStatus -eq $false) {
                    $result = $false
                    return $result
                }
            }
            else {
                Write-Verbose -Message 'No new version discovered. No action taken.'
            }
            #--------------------------------------------------------
            Write-Verbose -Message 'Evaluating slack send requirements...'
            if ($newVersionFound -eq $true) {
                Write-Verbose -Message 'New pwsh slack message needs sent.'
                $slackSplat = @{
                    Text        = $azReleaseInfo.AZTitle
                    Title       = 'New AZ PowerShell Release'
                    Link        = $azReleaseInfo.AZLink
                    MessageType = 'PowerShellVersion'
                }
                Send-SlackMessage @slackSplat
            }
            #--------------------------------------------------------
        } #if_Should
    } #process
    End {
        if ($result -eq $true) {
            return $result
        }
    } #end
} #Start-PowerShellAZCheck
