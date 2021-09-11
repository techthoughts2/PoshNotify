<#
.SYNOPSIS
    Retrieves the top 5 posts from /r/PowerShell and sends them in a properly formatted message.
.DESCRIPTION
    Engages the reddit.com site and returns the top 5 posts from /r/PowerShell subreddit and sends them in a properly formatted message.
.EXAMPLE
    Start-PowerShellRedditCheck

    Sends message containing the top 5 posts from /r/PowerShell.
.OUTPUTS
    None
.NOTES
    This took a lot longer to make than I thought it would.

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Start-PowerShellRedditCheck {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Skip confirmation')]
        [switch]$Force
    )
    begin {
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
        $result = $true #assume the best
        Write-Verbose -Message ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    }
    process {
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'
            if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
                Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
                $ConfirmPreference = 'None'

                #--------------------------------------------------------
                # get the weekly reddit information
                $powerShellRedditInfo = Get-Reddit -Subreddit 'PowerShell'
                if ($powerShellRedditInfo -eq $false) {
                    $result = $false
                    return $result
                }
                else {
                    Write-Verbose -Message 'Sending reddit PowerShell slack message...'
                    $slackSplat = @{
                        Text        = 'text'
                        Title       = 'title'
                        Link        = 'link'
                        MessageType = 'PowerShellReddit'
                        RedditObj   = $powerShellRedditInfo
                    }
                    Send-SlackMessage @slackSplat -verbose
                }
                #--------------------------------------------------------
            }
        }
    } #process
    end {
        if ($result -eq $true) {
            return $result
        }
    } #end

} #Start-PowerShellRedditCheck
