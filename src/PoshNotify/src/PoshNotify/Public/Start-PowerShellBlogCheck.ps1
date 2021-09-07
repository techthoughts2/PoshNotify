<#
.SYNOPSIS
    Evaluates if a new PowerShell blog post has been published and sends slack messages notifying of the post.
.DESCRIPTION
    Evaluates PowerShell rss feed. If a blog blob is not found, one will be populated. The blog blob will be evaluated against rss information to determine if a new post is available. If it is, the table will be updated and slack messages will be sent. Blob will be updated for most recent post.
.EXAMPLE
    Start-PowerShellBlogCheck

    Evalutes PowerShell blog rss, updates blog blob as required, sends slack messages as required.
.OUTPUTS
    None
.NOTES
    This took a lot longer to make than I thought it would.

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
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

    } #begin
    Process {
        $result = $true #assume the best
        # -Confirm --> $ConfirmPreference = 'Low'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose -Message ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            $ConfirmPreference = 'None'

            #region current rss information

            # get the current rss information
            $powerShellBlogInfo = Get-PowerShellBlogInfo
            if ($null -eq $powerShellBlogInfo) {
                $result = $false
                return $result
            }

            #endregion

            $outFile = $false # only 1 file is output - the latest post
            foreach ($post in $powerShellBlogInfo) {
                # resets
                $partitionKey = $script:psBlogData
                $rowKey = $null
                $getTableRowInfoSplat = $null
                $postTableInfo = $null
                $newBlogFound = $false

                $outTable = $false

                #region table checks

                # query the table to see if the post already exists
                $rowKey = $post.GUID
                $getTableRowInfoSplat = @{
                    PartitionKey = $partitionKey
                    RowKey       = $rowKey
                }
                $postTableInfo = Get-TableRowInfo @getTableRowInfoSplat
                #--------------------------------------------------------
                if ($postTableInfo -eq $false) {
                    Write-Warning 'Table could not be properly queried.'
                    $result = $false
                    return $result
                }
                #--------------------------------------------------------
                if ($null -eq $postTableInfo) {
                    # the table entry has never been created
                    Write-Verbose -Message ('Post is newer - {0}' -f $post.Title)
                    $newBlogFound = $true
                    $outTable = $true
                    $outFile = $true
                }
                else {
                    Write-Verbose -Message 'Record was found. PowerShell post is already in table.'
                }

                #endregion

                #region post processing

                if ($outTable -eq $true) {
                    Write-Verbose -Message 'New PowerShell post discovered. Adding row entry to table.'

                    $properties = [ordered]@{
                        Title   = $post.title
                        Link    = $post.link
                        PubDate = $post.pubDate
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
                    Write-Verbose -Message 'No new PowerShell post discovered. No table action taken.'
                }
                #--------------------------------------------------------
                Write-Verbose -Message 'Evaluating slack send requirements...'
                if ($newBlogFound -eq $true) {
                    Write-Verbose -Message 'New blog post slack message needs sent.'
                    $slackSplatPreview = @{
                        Text        = $post.title
                        Title       = 'New PowerShell Blog Posted'
                        Link        = $post.link
                        MessageType = 'PowerShellBlog'
                    }
                    Send-SlackMessage @slackSplatPreview
                }
                #--------------------------------------------------------

                #endregion

            } #foreach_post

            #--------------------------------------------------------
            if ($outFile -eq $true) {
                # only blob update the most recent blog post
                $mostRecentPwshPost = $powerShellBlogInfo | Sort-Object guid -Descending | Select-Object -First 1
                Write-Verbose -Message 'New blog post discovered. Updating blog blob.'
                $psBlogXML = ConvertTo-Clixml -InputObject $mostRecentPwshPost -Depth 100
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

        } #if_Should
    } #process
    End {
        if ($result -eq $true) {
            return $result
        }
    } #end
} #Start-PowerShellBlogCheck
