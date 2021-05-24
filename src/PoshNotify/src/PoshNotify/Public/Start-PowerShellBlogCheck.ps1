<#
.SYNOPSIS
    Evaluates if a new PowerShell blog post has been published and sends slack messages notifying of the post.
.DESCRIPTION
    Evaluates PowerShell rss feed. If a blog blob is not found, one will be populated. The blog blob will be evaluated against rss information to determine if a new post is available. If it is, the blob will be updated and slack messages will be sent.
.EXAMPLE
    Start-PowerShellBlogCheck

    Evalutes PowerShell blog rss, updates blog blob as required, sends slack messages as required.
.OUTPUTS
    None
.NOTES
    This took a lot longer to make than I thought it would.
.COMPONENT
    PoshNotify
#>
function Start-PowerShellBlogCheck {
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

        $newBlogFound = $false
        $outFile = $false

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'

            #--------------------------------------------------------
            # get the current rss information
            $powerShellBlogInfo = Get-PowerShellBlogInfo
            if ($null -eq $powerShellBlogInfo) {
                $result = $false
                return $result
            }
            #--------------------------------------------------------
            # get the PowerShell blog info from the blob for comparison
            $powerShellBlobBlogInfo = Get-BlobVersionInfo -Blob $script:psBlogData
            switch ($powerShellBlobBlogInfo) {
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
                    if ([datetime]$powerShellBlogInfo.Date -gt [datetime]$powerShellBlobBlogInfo.Date) {
                        Write-Verbose -Message 'Blog post is newer.'
                        $newBlogFound = $true
                        $outFile = $true
                    }
                }
            }
            #--------------------------------------------------------
            if ($outFile -eq $true) {
                Write-Verbose -Message 'New blog post discovered. Updating blog blob.'
                $psBlogXML = ConvertTo-Clixml -InputObject $powerShellBlogInfo -Depth 100
                $psBlogXML | Out-File -FilePath "$env:TEMP\$script:psBlogData" -ErrorAction Stop

                $setBlobVersionSplat = @{
                    Blob  = $script:psBlogData
                    File  = "$env:TEMP\$script:psBlogData"
                    Force = $true
                }
                $blobStatus = Set-BlobVersionInfo @setBlobVersionSplat
                if ($blobStatus -eq $false) {
                    $result = $false
                    return $result
                }
            }
            else {
                Write-Verbose -Message 'No new blog post discovered. No action taken.'
            }
            #--------------------------------------------------------
            Write-Verbose -Message 'Evaluating slack send requirements...'
            if ($newBlogFound -eq $true) {
                Write-Verbose -Message 'New blog post slack message needs sent.'
                $slackSplatPreview = @{
                    Text        = $powerShellBlogInfo.Title
                    Title       = 'New PowerShell Blog Posted'
                    Link        = $powerShellBlogInfo.Link
                    MessageType = 'PowerShellBlog'
                }
                Send-SlackMessage @slackSplatPreview
            }
            #--------------------------------------------------------
        } #if_Should
    } #process
    End {
        if ($result -eq $true) {
            return $result
        }
    } #end
} #Start-PowerShellBlogCheck
