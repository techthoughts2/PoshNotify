<#
.SYNOPSIS
    Retrieves release information from azure-powershell Github
.DESCRIPTION
    Retrieves release information from the azure-powershell Github and parses and returns version information of latest releases.
.EXAMPLE
    Get-PowerShellAZReleaseInfo

    AZVersion        : 6.3.0
    AZTitle          : Az v6.3.0
    AZLink           : https://github.com/Azure/azure-powershell/releases/tag/v6.3.0-August2021
    AZPreviewVersion : 6.4.0
    AZPreviewTitle   : Az 6.4.0
    AZPreviewLink    : https://github.com/Azure/azure-powershell/releases/tag/v6.4.0-September2021
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Invoke-RestMethod
.COMPONENT
    PoshNotify
#>
function Get-PowerShellAZReleaseInfo {
    [CmdletBinding()]
    param (
    )
    $repoName = 'Azure/azure-powershell'

    $azReleaseInfo = Get-GitHubReleaseInfo -RepositoryName $repoName

    if ($null -eq $azReleaseInfo) {
        Write-Warning -Message 'No release information was returned from the GitHub API.'
        return $null
    }

    Write-Verbose -Message 'Processing AZ release information...'

    $azReleases = $azReleaseInfo | Where-Object { $_.name -notlike '*Az.*' }
    $azSortedByRelease = $azReleases | Sort-Object { $_.published_at -as [datetime] } -Descending
    $azPreview = $azSortedByRelease | Where-Object { $_.prerelease -eq $true } | Select-Object -First 1
    $az = $azSortedByRelease | Where-Object { $_.prerelease -eq $false } | Select-Object -First 1

    $azPreviewParse = $azPreview.name | Select-String -Pattern $script:versionRegex
    $azPreviewVersion = $azPreviewParse.Matches.Value

    $azParse = $az.name | Select-String -Pattern $script:versionRegex
    $azVersion = $azParse.Matches.Value

    Write-Verbose -Message 'Processing COMPLETE.'

    if ($null -eq $azPreviewVersion) {
        Send-TelegramError -ErrorMessage 'Get-PowerShellAZReleaseInfo did not parse the preview version number correctly.'
        return $null
    }
    if ($null -eq $azVersion) {
        Send-TelegramError -ErrorMessage 'Get-PowerShellAZReleaseInfo did not parse the version number correctly.'
        return $null
    }

    $obj = [PSCustomObject]@{
        AZVersion        = $azVersion
        AZTitle          = $az.name
        AZLink           = $az.html_url
        AZPreviewVersion = $azPreviewVersion
        AZPreviewTitle   = $azPreview.name
        AZPreviewLink    = $azPreview.html_url
    }

    return $obj
} #Get-PowerShellAZReleaseInfo
