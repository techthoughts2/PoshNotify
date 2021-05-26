<#
.SYNOPSIS
    Retrieves release information from PowerShell Github
.DESCRIPTION
    Retrieves atom release information from the PowerShell Github and parses and returns version information of latest releases.
.EXAMPLE
    Get-PowerShellReleaseInfo

    Preview      : 7.2.0
    PreviewRC    : 5
    PreviewTitle : v7.2.0-preview.5 Release of PowerShell
    PreviewLink  : https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.5
    Pwsh         : 7.1.3
    PwshTitle    : v7.1.3 Release of PowerShell
    PwshLink     : https://github.com/PowerShell/PowerShell/releases/tag/v7.1.3
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Invoke-RestMethod
.COMPONENT
    PoshNotify
#>
function Get-PowerShellReleaseInfo {
    [CmdletBinding()]
    param (
    )

    $invokeRestSplat = @{
        Uri         = 'https://github.com/PowerShell/PowerShell/releases.atom'
        OutFile     = $path
        ErrorAction = 'Stop'
    }
    Write-Verbose -Message 'Retrieving release information from PowerShell github.'

    try {
        $pwshrss = Invoke-RestMethod @invokeRestSplat
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage 'Get-PowerShellReleaseInfo could not retrieve release info from PowerShell Github.'
        return $null
    }

    Write-Verbose -Message 'Processing data to retrieve version info...'
    $pwshReleaseSortedByRelease = $pwshrss | Sort-Object { $_."updated" -as [datetime] } -Descending
    $pwshReleasePreview = $pwshReleaseSortedByRelease | Where-Object { $_.id -like "*preview*" } | Select-Object -First 1
    $pwshRelease = $pwshReleaseSortedByRelease | Where-Object { $_.id -notlike "*preview*" } | Select-Object -First 1

    $releaseSplit = $pwshReleasePreview.id.Split('/v')[1]
    [version]$pwshReleasePreviewVersion = $releaseSplit.Split('-')[0]
    $pwshReleasePreviewCandidate = $releaseSplit.Split('preview.')[1]
    [version]$pwshReleaseVersion = $pwshRelease.id.Split('/v')[1]

    $obj = [PSCustomObject]@{
        Preview      = $pwshReleasePreviewVersion
        PreviewRC    = $pwshReleasePreviewCandidate
        PreviewTitle = $pwshReleasePreview.title
        PreviewLink  = $pwshReleasePreview.link.href
        Pwsh         = $pwshReleaseVersion
        PwshTitle    = $pwshRelease.title
        PwshLink     = $pwshRelease.link.href
    }

    Write-Verbose -Message 'Processing COMPLETE.'

    return $obj
} #Get-PowerShellReleaseInfo
