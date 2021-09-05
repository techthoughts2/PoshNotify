<#
.SYNOPSIS
    Retrieves release information from the GitHub release API for a given GitHub repository
.DESCRIPTION
    Queries the GitHub release API for the provided GitHub repository and retrieves release information.
.EXAMPLE
    Get-GitHubReleaseInfo -RepositoryName 'Azure/azure-powershell'

    Returns full release information from the GitHub release API for the provided repository.
.PARAMETER RepositoryName
    GitHub repository name path
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Invoke-RestMethod

    The GitHub Token is sourced from the Azure function env variables

    Jake Morrison - @jakemorrison - https://www.techthoughts.info
.COMPONENT
    PoshNotify
#>
function Get-GitHubReleaseInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'GitHub repository name path')]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryName
    )

    $env:GITHUB_API_TOKEN = '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'
    $uri = 'https://api.github.com/repos/{0}/releases' -f $RepositoryName
    $invokeWebRequestSplat = @{
        Uri         = $uri
        Headers     = @{Authorization = "Bearer $env:GITHUB_API_TOKEN" }
        # Method = $method
        ContentType = 'application/json'
        ErrorAction = 'Stop'
    }

    Write-Verbose -Message ('Retrieving GitHub release information from: {0}' -f $uri)
    try {
        $githubProjectInfo = Invoke-RestMethod @invokeWebRequestSplat
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage ('Get-GitHubReleaseInfo could not retrieve release info for: {0}' -f $RepositoryName)
        return $null
    }

    return $githubProjectInfo

} #Get-GitHubReleaseInfo
