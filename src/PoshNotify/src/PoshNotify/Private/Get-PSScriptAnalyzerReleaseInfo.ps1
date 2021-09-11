<#
.SYNOPSIS
    Retrieves release information from PSScriptAnalyzer Github
.DESCRIPTION
    Retrieves release information from the PSScriptAnalyzer Github and parses and returns version information of latest releases.
.EXAMPLE
    Get-PSScriptAnalyzerReleaseInfo

    PSSAVersion : 1.20.0
    PSSATitle   : PSScriptAnalyzer v1.20.0
    PSSALink    : https://github.com/PowerShell/PSScriptAnalyzer/releases/tag/1.20.0
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Invoke-RestMethod

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Get-PSScriptAnalyzerReleaseInfo {
    [CmdletBinding()]
    param (
    )

    $repoName = 'PowerShell/PSScriptAnalyzer'

    $pssaReleaseInfo = Get-GitHubReleaseInfo -RepositoryName $repoName

    if ($null -eq $pssaReleaseInfo) {
        Write-Warning -Message 'No release information was returned from the GitHub API.'
        return $null
    }

    Write-Verbose -Message 'Processing PSScriptAnalyzer release information...'

    $pssaSortedByRelease = $pssaReleaseInfo | Sort-Object { $_.published_at -as [datetime] } -Descending

    $pssa = $pssaSortedByRelease | Where-Object { $_.prerelease -eq $false } | Select-Object -First 1

    $pssaParse = $pssa.name | Select-String -Pattern $script:versionRegex
    $pssaVersion = $pssaParse.Matches.Value

    Write-Verbose -Message 'Processing COMPLETE.'

    if ($null -eq $pssaVersion) {
        Send-TelegramError -ErrorMessage 'Get-PSScriptAnalyzerReleaseInfo did not parse the version number correctly.'
        return $null
    }

    $obj = [PSCustomObject]@{
        PSSAVersion = $pssaVersion
        PSSATitle   = $pssa.name
        PSSALink    = $pssa.html_url
    }

    Write-Verbose -Message 'Processing COMPLETE.'

    return $obj

} #Get-PSScriptAnalyzerReleaseInfo
