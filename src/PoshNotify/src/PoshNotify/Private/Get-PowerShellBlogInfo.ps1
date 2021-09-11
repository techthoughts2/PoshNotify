<#
.SYNOPSIS
    Retrieves rss information from the PowerShell blog
.DESCRIPTION
    Retrieves rss feed information from the PowerShell blog and parses and returns post information.
.EXAMPLE
    Get-PowerShellBlogInfo

    GUID    : 19144
    title   : PSArm Experiment Update
    link    : https://devblogs.microsoft.com/powershell/psarm-experiment-update/
    pubDate : Wed, 11 Aug 2021 23:47:32 +0000
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

    # $mostRecentPost = $powerShellFeed[0]

    $objReturn = $powerShellFeed | Select-Object @{N = "GUID"; E = { $_.guid.'#text' } }, title, link, pubDate

    foreach ($post in $objReturn) {
        if ($post.GUID -notlike 'https://*?p=*') {
            Send-TelegramError -ErrorMessage 'Get-PowerShellBlogInfo XML processing failed.'
            return $null
        }
    }

    $objReturn | ForEach-Object {
        $temp = $null
        $temp = $_.GUID.Split('?p=')
        $_.GUID = $temp[1]
    }

    Write-Verbose -Message 'XML Processing COMPLETE.'

    return $objReturn
} #Get-PowerShellBlogInfo
