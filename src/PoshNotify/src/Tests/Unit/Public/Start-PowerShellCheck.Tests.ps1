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

InModuleScope 'PoshNotify' {
    #-------------------------------------------------------------------------
    $WarningPreference = 'SilentlyContinue'
    #-------------------------------------------------------------------------
    BeforeAll {
        $WarningPreference = 'SilentlyContinue'
        $ErrorActionPreference = 'SilentlyContinue'
    }
    Context 'Start-PowerShellCheck' {
        function Send-SlackMessage {
        }
        function ConvertTo-Clixml {
        }
        function Out-File {
        }
        BeforeEach {
            Mock -CommandName Get-PowerShellReleaseInfo -MockWith {
                [PSCustomObject]@{
                    Preview      = '7.2.0'
                    PreviewRC    = '5'
                    PreviewTitle = 'v7.2.0-preview.5 Release of PowerShell'
                    PreviewLink  = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.5'
                    Pwsh         = '7.1.3'
                    PwshTitle    = 'v7.1.3 Release of PowerShell'
                    PwshLink     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.3'
                }
            } #endMock
            Mock -CommandName Get-BlobVersionInfo -MockWith {
                [PSCustomObject]@{
                    Preview      = '7.2.0'
                    PreviewRC    = '5'
                    PreviewTitle = 'v7.2.0-preview.5 Release of PowerShell'
                    PreviewLink  = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.5'
                    Pwsh         = '7.1.3'
                    PwshTitle    = 'v7.1.3 Release of PowerShell'
                    PwshLink     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.3'
                }
            } #endMock
            Mock -CommandName Set-BlobVersionInfo -MockWith {
                $true
            } #endMock
            Mock -CommandName Send-SlackMessage -MockWith {
                $null
            } #endMock
        } #beforeeach
        Context 'ShouldProcess' {
            BeforeEach {
                Mock -CommandName Start-PowerShellCheck -MockWith { } #endMock
            } #beforeEach
            It 'Should process by default' {
                Start-PowerShellCheck
                Assert-MockCalled Start-PowerShellCheck -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Start-PowerShellCheck }
                Assert-MockCalled Start-PowerShellCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Start-PowerShellCheck
                }
                Assert-MockCalled Start-PowerShellCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Start-PowerShellCheck }
                Assert-MockCalled Start-PowerShellCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Start-PowerShellCheck
                }
                Assert-MockCalled Start-PowerShellCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Start-PowerShellCheck
                Assert-MockCalled Start-PowerShellCheck -Scope It -Exactly -Times 1
            } #it
        } #context
        Context 'Error' {
            It 'should return false if no Powershell version information is found' {
                Mock -CommandName Get-PowerShellReleaseInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellCheck | Should -BeExactly $false
            } #it
            It 'should return false if no version information is found from blob' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Set-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Mock -CommandName Get-PowerShellReleaseInfo -MockWith {
                    [PSCustomObject]@{
                        Preview      = '7.3.0'
                        PreviewRC    = '6'
                        PreviewTitle = 'v7.3.0-preview.6 Release of PowerShell'
                        PreviewLink  = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.6'
                        Pwsh         = '7.2.3'
                        PwshTitle    = 'v7.2.3 Release of PowerShell'
                        PwshLink     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.3'
                    }
                } #endMock
                Start-PowerShellCheck | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should not throw if a new version is not discovered' {
                { Start-PowerShellCheck } | Should -Not -Throw
            } #it
            It 'should not send slack messages if a new version is not discovered' {
                Start-PowerShellCheck
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 0
            } #it
            It 'should not update the blob if a new version is not discovered' {
                Start-PowerShellCheck
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'should not throw if a new version is discovered' {
                Mock -CommandName Get-PowerShellReleaseInfo -MockWith {
                    [PSCustomObject]@{
                        Preview      = '7.2.0'
                        PreviewRC    = '6'
                        PreviewTitle = 'v7.2.0-preview.5 Release of PowerShell'
                        PreviewLink  = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.6'
                        Pwsh         = '7.2.3'
                        PwshTitle    = 'v7.2.3 Release of PowerShell'
                        PwshLink     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.3'
                    }
                } #endMock
                { Start-PowerShellCheck } | Should -Not -Throw
            } #it
            It 'should send slack messages if a new version is discovered' {
                Mock -CommandName Get-PowerShellReleaseInfo -MockWith {
                    [PSCustomObject]@{
                        Preview      = '7.3.0'
                        PreviewRC    = '6'
                        PreviewTitle = 'v7.3.0-preview.6 Release of PowerShell'
                        PreviewLink  = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.6'
                        Pwsh         = '7.2.3'
                        PwshTitle    = 'v7.2.3 Release of PowerShell'
                        PwshLink     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.3'
                    }
                } #endMock
                Start-PowerShellCheck
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 2
            } #it
            It 'should update the blob if a new version is discovered' {
                Mock -CommandName Get-PowerShellReleaseInfo -MockWith {
                    [PSCustomObject]@{
                        Preview      = '7.2.0'
                        PreviewRC    = '6'
                        PreviewTitle = 'v7.2.0-preview.5 Release of PowerShell'
                        PreviewLink  = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.6'
                        Pwsh         = '7.2.3'
                        PwshTitle    = 'v7.2.3 Release of PowerShell'
                        PwshLink     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.3'
                    }
                } #endMock
                Start-PowerShellCheck
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
            } #it
            It 'should not throw if the blob has never been created before' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                { Start-PowerShellCheck } | Should -Not -Throw
            } #it
            It 'should return true if no issues are encountered' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellCheck | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
