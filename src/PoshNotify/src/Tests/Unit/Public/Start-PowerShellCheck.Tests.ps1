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
        BeforeEach {
            function Send-SlackMessage {
            }
            function ConvertTo-Clixml {
            }
            function Out-File {
            }
            Mock -CommandName Get-PowerShellReleaseInfo -MockWith {
                [PSCustomObject]@{
                    PwshVersion        = '7.1.4'
                    PwshTitle          = 'v7.1.4 Release of PowerShell'
                    PwshLink           = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                    PwshPreviewVersion = '7.2.0'
                    PwshPreviewTitle   = 'v7.2.0-preview.9 Release of PowerShell'
                    PwshPreviewLink    = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.9'
                    PwshPreviewRC      = '9'
                }
            } #endMock
            Mock -CommandName Get-TableRowInfo -MockWith {
                [PSCustomObject]@{
                    PartitionKey   = 'pwsh'
                    RowKey         = '7.1.4'
                    Title          = 'v7.1.4 Release of PowerShell'
                    Link           = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                    TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                    Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                }
            } #endMock
            # Mock -CommandName Get-BlobVersionInfo -MockWith {
            #     [PSCustomObject]@{
            #         Preview      = '7.2.0'
            #         PreviewRC    = '5'
            #         PreviewTitle = 'v7.2.0-preview.5 Release of PowerShell'
            #         PreviewLink  = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.5'
            #         Pwsh         = '7.1.3'
            #         PwshTitle    = 'v7.1.3 Release of PowerShell'
            #         PwshLink     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.3'
            #     }
            # } #endMock
            Mock -CommandName Set-TableVersionInfo -MockWith {
                $true
            } #endMock
            Mock -CommandName Set-BlobVersionInfo -MockWith {
                $true
            } #endMock
            Mock -CommandName Send-SlackMessage -MockWith {
                $null
            } #endMock
            Mock -CommandName Send-SlackMessage -MockWith {} #endMock
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
            It 'should return false if an issue is encountered getting table information' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellCheck | Should -BeExactly $false
            } #it
            # It 'should return false if no version information is found from blob' {
            #     Mock -CommandName Get-BlobVersionInfo -MockWith {
            #         $null
            #     } #endMock
            #     Start-PowerShellCheck | Should -BeExactly $false
            # } #it
            It 'should return false if table is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-TableVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellCheck | Should -BeExactly $false
            } #it
            It 'should return false if table is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $true
                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $false
                    }
                }
                Mock -CommandName Set-TableVersionInfo -MockWith $mockInvoke

                Start-PowerShellCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $true
                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $false
                    }
                }
                Mock -CommandName Set-BlobVersionInfo -MockWith $mockInvoke

                Start-PowerShellCheck | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should not update anything or send messages if no new versions are found' {
                Start-PowerShellCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 0
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 0
            } #it
            It 'should only update and send 1 message if new version is found' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        return $null
                    }
                    elseif ($script:mockCalled -eq 2) {
                        $mock = [PSCustomObject]@{
                            PartitionKey   = 'pwsh'
                            RowKey         = '7.1.4'
                            Title          = 'v7.1.4 Release of PowerShell'
                            Link           = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                            TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                            Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                        }
                        return $mock
                    }
                }
                Mock -CommandName Get-TableRowInfo -MockWith $mockInvoke

                Start-PowerShellCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 1
            } #it
            It 'should only update and send 1 message if new preview version is found' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        $mock = [PSCustomObject]@{
                            PartitionKey   = 'pwsh'
                            RowKey         = '7.1.4'
                            Title          = 'v7.1.4 Release of PowerShell'
                            Link           = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                            TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                            Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                        }
                        return $mock

                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $null
                    }
                }
                Mock -CommandName Get-TableRowInfo -MockWith $mockInvoke

                Start-PowerShellCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 1
            } #it
            It 'should perform the updates for PowerShell version with the correct parameters' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {

                        return $null
                    }
                    elseif ($script:mockCalled -eq 2) {
                        $mock = [PSCustomObject]@{
                            PartitionKey   = 'pwsh'
                            RowKey         = '7.1.4'
                            Title          = 'v7.1.4 Release of PowerShell'
                            Link           = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                            TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                            Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                        }
                        return $mock
                    }
                }
                Mock -CommandName Get-TableRowInfo -MockWith $mockInvoke
                Mock -CommandName Set-TableVersionInfo {
                    $PartitionKey | Should -BeExactly 'pwsh'
                    $RowKey | Should -BeExactly '7.1.4'
                } -Verifiable
                Mock -CommandName Set-BlobVersionInfo {
                    $Blob | Should -BeExactly 'pwsh'
                } -Verifiable
                Start-PowerShellCheck
                Assert-VerifiableMock
            } #it
            It 'should perform the updates for PowerShell preview version with the correct parameters' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        $mock = [PSCustomObject]@{
                            PartitionKey   = 'pwsh'
                            RowKey         = '7.1.4'
                            Title          = 'v7.1.4 Release of PowerShell'
                            Link           = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                            TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                            Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                        }
                        return $mock

                    }
                    elseif ($script:mockCalled -eq 2) {
                        return $null
                    }
                }
                Mock -CommandName Get-TableRowInfo -MockWith $mockInvoke
                Mock -CommandName Set-TableVersionInfo {
                    $PartitionKey | Should -BeExactly 'pwshpreview'
                    $RowKey | Should -BeExactly '7.2.0'
                } -Verifiable
                Mock -CommandName Set-BlobVersionInfo {
                    $Blob | Should -BeExactly 'pwshpreview'
                } -Verifiable
                Start-PowerShellCheck
                Assert-VerifiableMock
            } #it
            It 'should return true if no issues are encountered' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellCheck | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
