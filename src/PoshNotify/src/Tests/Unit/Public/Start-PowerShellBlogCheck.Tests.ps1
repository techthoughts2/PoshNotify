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
    Context 'Start-PowerShellBlogCheck' {
        function Send-SlackMessage {
        }
        function ConvertTo-Clixml {
        }
        function Out-File {
        }
        BeforeEach {
            Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                [PSCustomObject]@{
                    Title = 'Announcing PlatyPS 2.0.0-Preview1'
                    Link  = 'https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/'
                    Date  = 'Thu, 20 May 2021 19:08:32 +0000'
                }
            } #endMock
            Mock -CommandName Get-BlobVersionInfo -MockWith {
                [PSCustomObject]@{
                    Title = 'Announcing PlatyPS 2.0.0-Preview1'
                    Link  = 'https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/'
                    Date  = 'Thu, 20 May 2021 19:08:32 +0000'
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
            Mock -CommandName Start-PowerShellBlogCheck -MockWith { } #endMock
            It 'Should process by default' {
                Start-PowerShellBlogCheck
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 1
            }#it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Start-PowerShellBlogCheck }
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Start-PowerShellBlogCheck
                }
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Start-PowerShellBlogCheck }
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Start-PowerShellBlogCheck
                }
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Start-PowerShellBlogCheck
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 1
            }#it
        } #context
        Context 'Error' {
            It 'should return false if no Powershell blog information is found' {
                Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellBlogCheck | Should -BeExactly $false
            } #it
            It 'should return false if no new blog is found from blob' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellBlogCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Set-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                    [PSCustomObject]@{
                        Title = 'Announcing PowerShell 8 - Holy Smokes!'
                        Link  = 'https://devblogs.microsoft.com/powershell/announcing-powershell-8/'
                        Date  = 'Fri, 22 May 2026 19:08:32 +0000'
                    }
                } #endMock
                Start-PowerShellBlogCheck | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should not throw if a new post is not discovered' {
                { Start-PowerShellBlogCheck } | Should Not Throw
            } #it
            It 'should not send slack messages if a new post is not discovered' {
                Start-PowerShellBlogCheck
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 0
            } #it
            It 'should not update the blob if a new post is not discovered' {
                Start-PowerShellBlogCheck
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'should not throw if a new post is discovered' {
                Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                    [PSCustomObject]@{
                        Title = 'Announcing PowerShell 8 - Holy Smokes!'
                        Link  = 'https://devblogs.microsoft.com/powershell/announcing-powershell-8/'
                        Date  = 'Fri, 22 May 2026 19:08:32 +0000'
                    }
                } #endMock
                { Start-PowerShellBlogCheck } | Should Not Throw
            } #it
            It 'should send slack messages if a new post is discovered' {
                Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                    [PSCustomObject]@{
                        Title = 'Announcing PowerShell 8 - Holy Smokes!'
                        Link  = 'https://devblogs.microsoft.com/powershell/announcing-powershell-8/'
                        Date  = 'Fri, 22 May 2026 19:08:32 +0000'
                    }
                } #endMock
                Start-PowerShellBlogCheck
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 1
            } #it
            It 'should update the blob if a new post is discovered' {
                Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                    [PSCustomObject]@{
                        Title = 'Announcing PowerShell 8 - Holy Smokes!'
                        Link  = 'https://devblogs.microsoft.com/powershell/announcing-powershell-8/'
                        Date  = 'Fri, 22 May 2026 19:08:32 +0000'
                    }
                } #endMock
                Start-PowerShellBlogCheck
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
            } #it
            It 'should not throw if the blob has never been created before' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                { Start-PowerShellBlogCheck } | Should Not Throw
            } #it
            It 'should return true if no issues are encountered' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellBlogCheck | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
