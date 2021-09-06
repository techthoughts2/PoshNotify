<#
.SYNOPSIS
    Retrieves release information from PowerShell Github
.DESCRIPTION
    Retrieves release information from the PowerShell Github and parses and returns version information of latest releases.
.EXAMPLE
    Get-PowerShellReleaseInfo

    PwshVersion        : 7.1.4
    PwshTitle          : v7.1.4 Release of PowerShell
    PwshLink           : https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4
    PwshPreviewVersion : 7.2.0
    PwshPreviewTitle   : v7.2.0-preview.9 Release of PowerShell
    PwshPreviewLink    : https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.9
    PwshPreviewRC      : 9
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Invoke-RestMethod

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Get-PowerShellReleaseInfo {
    [CmdletBinding()]
    param (
    )

    $repoName = 'PowerShell/PowerShell'

    $pwshReleaseInfo = Get-GitHubReleaseInfo -RepositoryName $repoName

    Write-Verbose -Message 'Release Info for PWSH:'
    Write-Verbose ($pwshReleaseInfo | Out-String)
    if ($null -eq $pwshReleaseInfo) {
        Write-Warning -Message 'No release information was returned from the GitHub API.'
        return $null
    }

    Write-Verbose -Message 'Processing pwsh release information...'

    $pwshSortedByRelease = $pwshReleaseInfo | Sort-Object { $_.published_at -as [datetime] } -Descending

    $pwsh = $pwshSortedByRelease | Where-Object { $_.prerelease -eq $false } | Select-Object -First 1
    $pwshPreview = $pwshSortedByRelease | Where-Object { $_.prerelease -eq $true } | Select-Object -First 1

    $pwshParse = $pwsh.name | Select-String -Pattern $script:versionRegex
    $pwshVersion = $pwshParse.Matches.Value

    $pwshPreviewParse = $pwshPreview.name | Select-String -Pattern $script:versionRegex
    $pwshPreviewVersion = $pwshPreviewParse.Matches.Value

    $rcMatch = ($pwshPreview.Name | Select-String -Pattern 'preview.\d').Matches.Value
    $rcCandidate = $rcMatch.substring($rcMatch.length - 1)

    Write-Verbose -Message 'Processing COMPLETE.'

    if ($null -eq $pwshVersion) {
        Send-TelegramError -ErrorMessage 'Get-PowerShellReleaseInfo did not parse the version number correctly.'
        return $null
    }
    if ($null -eq $pwshPreviewVersion) {
        Send-TelegramError -ErrorMessage 'Get-PowerShellReleaseInfo did not parse the preview version number correctly.'
        return $null
    }

    $obj = [PSCustomObject]@{
        PwshVersion        = $pwshVersion
        PwshTitle          = $pwsh.name
        PwshLink           = $pwsh.html_url
        PwshPreviewVersion = $pwshPreviewVersion
        PwshPreviewTitle   = $pwshPreview.name
        PwshPreviewLink    = $pwshPreview.html_url
        PwshPreviewRC      = $rcCandidate
    }

    Write-Verbose -Message 'Processing COMPLETE.'

    return $obj

} #Get-PowerShellReleaseInfo
