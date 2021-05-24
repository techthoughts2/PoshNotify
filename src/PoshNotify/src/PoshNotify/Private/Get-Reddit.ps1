<#
.SYNOPSIS
    PowerShell based interactive reddit browser
.DESCRIPTION
    Uses PowerShell to establish a connection to reddit and pulls down a JSON payload for the specified subreddit.  The number of threads (default 3) specified by the user is then evaluated and output to the console window.  If the thread is picture-based the user has the option to display those images in their native browser.
.PARAMETER Subreddit
    The name of the desired subreddit - Ex PowerShell or aww
.PARAMETER Threads
    The number of threads that will be pulled down - the default is 3
.EXAMPLE
    Get-Reddit -Subreddit PowerShell
    Retrieves the top 5 threads of the PowerShell subreddit for the week
.NOTES
    Jake Morrison - @jakemorrison - https://www.techthoughts.info
#>
function Get-Reddit {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            Position = 1,
            HelpMessage = 'The name of the desired subreddit')]
        [string]$Subreddit,

        [Parameter(Mandatory = $false,
            Position = 2,
            HelpMessage = 'The number of threads that will be pulled down')]
        [ValidateRange(1, 25)]
        [int]$Threads = 5
    )

    #https://www.reddit.com/r/PowerShell/top/?sort=top&t=week/.json

    Write-Verbose -Message "Specified subreddit: $Subreddit"
    Write-Verbose -Message "Specified # of threads: $Threads"

    $results = [System.Collections.ArrayList]@()

    Write-Verbose -Message "Initiating Download"
    $uri = "https://www.reddit.com/r/$Subreddit/top/.json?sort=top&t=week"
    Write-Verbose -Message "URI: $uri"

    try {
        $invokeWebRequestSplat = @{
            Uri         = $uri
            ErrorAction = 'Stop'
        }
        $rawReddit = Invoke-WebRequest @invokeWebRequestSplat
        Write-Verbose -Message "Download successful."
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage '\\\ Project PoshNotify - Get-Reddit encountered an error retrieving reddit information.'
        $results = $false
        return $results
    }

    if ($rawReddit) {

        Write-Verbose -Message "Converting JSON..."
        $redditInfo = $rawReddit.Content | ConvertFrom-Json

        Write-Verbose -Message "Generating output..."
        for ($i = 0; $i -lt $Threads; $i++) {
            $childObject = $null #reset
            $childObject = $redditInfo.data.children.data[$i]
            if ($childObject.url -like "*/r/*" -and $childObject.url -notlike "*reddit.com*") {
                $childObject.url = "https://www.reddit.com" + $childObject.url
            }
            $obj = [PSCustomObject]@{
                Title = $childObject.title
                URL   = $childObject.url
                # PermaLink = $childObject.permalink
                # Score    = $childObject.score
                # Ups       = $childObject.ups
                # Downs     = $childObject.downs
                # Author   = $childObject.author
                # Comments = $childObject.num_comments
            }
            $results.Add($obj) | Out-Null
        }
    }#if_rawReddit
    else {
        $results = $false
        Write-Warning -Message 'No information was returned from reddit.'
        return $results
    }#else_rawReddit

    return $results

} #Get-Reddit
