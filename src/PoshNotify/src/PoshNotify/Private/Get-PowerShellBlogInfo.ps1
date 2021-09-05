<#
.SYNOPSIS
    Retrieves rss information from the PowerShell blog
.DESCRIPTION
    Retrieves rss feed information from the PowerShell blog and parses and returns version information of posts.
.EXAMPLE
    Get-PowerShellBlogInfo

    Title : Announcing PlatyPS 2.0.0-Preview1
    Link  : https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/
    Date  : Thu, 20 May 2021 19:08:32 +0000
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Invoke-RestMethod

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Get-PowerShellBlogInfo {
    param (
    )
    $invokeRestSplat = @{
        Uri         = 'https://devblogs.microsoft.com/powershell/feed/'
        ErrorAction = 'Stop'
    }
    Write-Verbose -Message 'Retrieving rss information from PowerShell blog.'
    try {

        $powerShellFeed = Invoke-RestMethod @invokeRestSplat
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage 'Get-PowerShellBlogInfo could not retrieve rss info from PowerShell blog.'
        return $null
    }

    Write-Verbose -Message 'Processing xml data to retrieve latest post information...'

    $mostRecentPost = $powerShellFeed[0]

    $obj = [PSCustomObject]@{
        Title = $mostRecentPost.title
        Link  = $mostRecentPost.link
        Date  = $mostRecentPost.pubDate
    }

    Write-Verbose -Message 'XML Processing COMPLETE.'

    return $obj
} #Get-PowerShellBlogInfo
