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
    # $WarningPreference = 'SilentlyContinue'
    # $ErrorActionPreference = 'SilentlyContinue'
    #-------------------------------------------------------------------------
    Context 'Start-PowerShellRedditCheck' {
        function Send-SlackMessage {
        }
        $redditInfo = [System.Collections.ArrayList]@()
        $obj1 = [PSCustomObject]@{
            Title = 'Proud noob moment'
            URL   = 'https://www.reddit.com/r/PowerShell/comment'
        }
        $obj2 = [PSCustomObject]@{
            Title = 'Network Troubleshooting w/ PowerShell'
            URL   = 'https://youtu.be/s-Ba4chiNh4'
        }
        $obj3 = [PSCustomObject]@{
            Title = 'Audit Office 365 External Sharing Activities - Never Allow the Resources Fall into Wrong Hands'
            URL   = 'https://www.reddit.com/r/Office365/'
        }
        $obj4 = [PSCustomObject]@{
            Title = 'IE11 desktop app retirement - June 15, 2022'
            URL   = 'https://www.reddit.com/r/PowerShell/comment'
        }
        $obj5 = [PSCustomObject]@{
            Title = 'I like making dumb little games in PowerShell. My latest is Hangman. Clues sourced from Wheel of Fortune.'
            URL   = 'https://www.reddit.com/r/PowerShell/comment'
        }
        $redditInfo.Add($obj1) | Out-Null
        $redditInfo.Add($obj2) | Out-Null
        $redditInfo.Add($obj3) | Out-Null
        $redditInfo.Add($obj4) | Out-Null
        $redditInfo.Add($obj5) | Out-Null
        BeforeEach {
            Mock -CommandName Get-Reddit -MockWith {
                $redditInfo
            } #endMock
            # Mock -CommandName Send-SlackMessage -MockWith {
            #     'fuck'
            # } #endMock
        } #beforeeach
        Context 'ShouldProcess' {
            Mock -CommandName Start-PowerShellRedditCheck -MockWith { } #endMock
            It 'Should process by default' {
                Start-PowerShellRedditCheck
                Assert-MockCalled Start-PowerShellRedditCheck -Scope It -Exactly -Times 1
            }#it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Start-PowerShellRedditCheck }
                Assert-MockCalled Start-PowerShellRedditCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Start-PowerShellRedditCheck
                }
                Assert-MockCalled Start-PowerShellRedditCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Start-PowerShellRedditCheck }
                Assert-MockCalled Start-PowerShellRedditCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Start-PowerShellRedditCheck
                }
                Assert-MockCalled Start-PowerShellRedditCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Start-PowerShellRedditCheck
                Assert-MockCalled Start-PowerShellRedditCheck -Scope It -Exactly -Times 1
            }#it
        } #context
        Context 'Error' {
            It 'should return false if no Powershell reddit information is found' {
                Mock -CommandName Get-Reddit -MockWith {
                    $false
                } #endMock
                Start-PowerShellRedditCheck | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should return true if no issues are encountered' {
                Start-PowerShellRedditCheck | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
