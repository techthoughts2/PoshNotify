<#
.SYNOPSIS
    Retrieves release information from azure-powershell Github
.DESCRIPTION
    Retrieves atom release information from the azure-powershell Github and parses and returns version information of latest releases.
.EXAMPLE
    Get-PowerShellAZReleaseInfo

    AZVersion : 6.0.0
    AZTitle   : Az 6.0.0
    AZLink    : https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021
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

    $invokeRestSplat = @{
        Uri         = 'https://github.com/Azure/azure-powershell/releases.atom'
        OutFile     = $path
        ErrorAction = 'Stop'
    }
    Write-Verbose -Message 'Retrieving release information from azure-powershell Github.'

    try {
        $azrss = Invoke-RestMethod @invokeRestSplat
    }
    catch {
        Write-Error $_
        Send-TelegramError -ErrorMessage 'Get-PowerShellAZReleaseInfo could not retrieve release info from azure-powershell Github.'
        return $null
    }

    Write-Verbose -Message 'Processing data to retrieve version info...'
    $azSortedByRelease = $azrss | Sort-Object { $_."updated" -as [datetime] } -Descending
    $azRelease = $azSortedByRelease | Where-Object { $_.id -notlike "*preview*" -and $_.id -notlike "*Az.*" } | Select-Object -First 1

    $releaseSplit = $azRelease.title.Split('Az ')[1]
    [version]$azReleaseVersion = $releaseSplit

    $obj = [PSCustomObject]@{
        AZVersion = $azReleaseVersion
        AZTitle   = $azRelease.title
        AZLink    = $azRelease.link.href
    }

    Write-Verbose -Message 'Processing COMPLETE.'

    return $obj
} #Get-PowerShellAZReleaseInfo
