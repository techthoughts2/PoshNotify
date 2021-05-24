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
        id        = 'tag:github.com,2008:Repository/49609581/v7.2.0-preview.5'
        updated   = '2021-04-14T23:57:25Z'
        link      = 'link'
        title     = 'v7.2.0-preview.5 Release of PowerShell'
        content   = 'content'
        author    = 'author'
        thumbnail = 'thumbnail'
    }
    $obj2 = [PSCustomObject]@{
        id        = 'tag:github.com,2008:Repository/49609581/v7.1.3'
        updated   = '2021-03-11T23:29:58Z'
        link      = 'link'
        title     = 'v7.1.3 Release of PowerShell'
        content   = 'content'
        author    = 'author'
        thumbnail = 'thumbnail'
    }

    $releaseInfo.Add($obj1) | Out-Null
    $releaseInfo.Add($obj2) | Out-Null

    Context 'Get-PowerShellReleaseInfo' {
        BeforeEach {
            Mock -CommandName Invoke-RestMethod -MockWith {
                $releaseInfo
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if an error is encountered getting PowerShell Github data' {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    throw 'FakeError'
                } #endMock
                Get-PowerShellReleaseInfo | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should return expected results if successful' {
                $eval = Get-PowerShellReleaseInfo
                $eval.Preview.Major | Should -BeExactly 7
                $eval.Preview.Minor | Should -BeExactly 2
                $eval.PreviewRC | Should -BeExactly 5
                $eval.Pwsh.Major | Should -BeExactly 7
                $eval.Pwsh.Minor | Should -BeExactly 1
            } #it
        } #context-success
    } #context
} #inModule
