#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'PoshNotify'
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------
$WarningPreference = 'SilentlyContinue'
#-------------------------------------------------------------------------
#Import-Module $moduleNamePath -Force

InModuleScope 'PoshNotify' {
    #-------------------------------------------------------------------------
    $WarningPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'SilentlyContinue'
    #-------------------------------------------------------------------------
    function Send-TelegramError {
    }
    $releaseInfo = [System.Collections.ArrayList]@()
    $obj1 = [PSCustomObject]@{
        id        = 'tag:github.com,2008:Repository/23891194/v6.0.0-May2021'
        updated   = '2021-05-21T07:41:05Z'
        link      = 'link'
        title     = 'Az 6.0.0'
        content   = 'content'
        author    = 'author'
        thumbnail = 'thumbnail'
    }
    $obj2 = [PSCustomObject]@{
        id        = 'tag:github.com,2008:Repository/23891194/Az.Accounts-v2.2.77'
        updated   = '2021-05-12T10:27:42Z'
        link      = 'link'
        title     = 'Az.Accounts 2.2.77'
        content   = 'content'
        author    = 'author'
        thumbnail = 'thumbnail'
    }

    $releaseInfo.Add($obj1) | Out-Null
    $releaseInfo.Add($obj2) | Out-Null

    Context 'Get-PowerShellAZReleaseInfo' {
        BeforeEach {
            Mock -CommandName Invoke-RestMethod -MockWith {
                $releaseInfo
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if an error is encountered getting azure-powershell Github data' {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    throw 'FakeError'
                } #endMock
                Get-PowerShellAZReleaseInfo | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should return expected results if successful' {
                $eval = Get-PowerShellAZReleaseInfo
                $eval.AZVersion.Major | Should -BeExactly 6
                $eval.AZVersion.Minor | Should -BeExactly 0
            } #it
        } #context-success
    } #context
} #inModule
