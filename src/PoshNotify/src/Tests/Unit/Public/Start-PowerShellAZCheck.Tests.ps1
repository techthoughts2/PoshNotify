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
    Context 'Start-PowerShellAZCheck' {
        BeforeEach {
            function Send-SlackMessage {
            }
            function ConvertTo-Clixml {
            }
            function Out-File {
            }

            Mock -CommandName Get-PowerShellAZReleaseInfo -MockWith {
                [PSCustomObject]@{
                    AZVersion        = '6.3.0'
                    AZTitle          = 'Az v6.3.0'
                    AZLink           = 'https://github.com/Azure/azure-powershell/releases/tag/v6.3.0-August2021'
                    AZPreviewVersion = '6.4.0'
                    AZPreviewTitle   = 'Az 6.4.0'
                    AZPreviewLink    = 'https://github.com/Azure/azure-powershell/releases/tag/v6.4.0-September2021'
                }
            } #endMock
            Mock -CommandName Get-TableRowInfo -MockWith {
                [PSCustomObject]@{
                    PartitionKey   = 'az'
                    RowKey         = '6.0.0'
                    Title          = 'Az v6.0.0'
                    Link           = 'https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021'
                    TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                    Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                }
            } #endMock
            # Mock -CommandName Get-BlobVersionInfo -MockWith {
            #     [PSCustomObject]@{
            #         AZVersion = '6.0.0'
            #         AZTitle   = 'Az v6.0.0'
            #         AZLink    = 'https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021'
            #     }
            # } #endMock
            Mock -CommandName Set-TableVersionInfo -MockWith {
                $true
            } #endMock
            Mock -CommandName Set-BlobVersionInfo -MockWith {
                $true
            } #endMock
            Mock -CommandName Send-SlackMessage -MockWith {} #endMock
        } #beforeeach
        Context 'ShouldProcess' {
            BeforeEach {
                Mock -CommandName Start-PowerShellAZCheck -MockWith { } #endMock
            } #beforeEach
            It 'Should process by default' {
                Start-PowerShellAZCheck
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Start-PowerShellAZCheck }
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Start-PowerShellAZCheck
                }
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Start-PowerShellAZCheck }
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Start-PowerShellAZCheck
                }
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Start-PowerShellAZCheck
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 1
            } #it
        } #context
        Context 'Error' {
            It 'should return false if no Powershell version information is found' {
                Mock -CommandName Get-PowerShellAZReleaseInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $false
            } #it
            It 'should return false if an issue is encountered getting table information' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $false
            } #it
            # It 'should return false if no version information is found from blob' {
            #     Mock -CommandName Get-BlobVersionInfo -MockWith {
            #         $null
            #     } #endMock
            #     Start-PowerShellAZCheck | Should -BeExactly $false
            # } #it
            It 'should return false if table is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-TableVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $false
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

                Start-PowerShellAZCheck | Should -BeExactly $false
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

                Start-PowerShellAZCheck | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should not update anything or send messages if no new versions are found' {
                Start-PowerShellAZCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 0
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 0
            } #it
            It 'should 1' {

            } #it
            It 'should only update and send 1 message a new preview version is found' {

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
                            PartitionKey   = 'az'
                            RowKey         = '6.0.0'
                            Title          = 'Az v6.0.0'
                            Link           = 'https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021'
                            TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                            Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                        }
                        return $mock
                    }
                }
                Mock -CommandName Get-TableRowInfo -MockWith $mockInvoke

                Start-PowerShellAZCheck
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
                            PartitionKey   = 'az'
                            RowKey         = '6.0.0'
                            Title          = 'Az v6.0.0'
                            Link           = 'https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021'
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

                Start-PowerShellAZCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 1
            } #it
            It 'should perform the az updates with the correct parameters' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {

                        return $null
                    }
                    elseif ($script:mockCalled -eq 2) {
                        $mock = [PSCustomObject]@{
                            PartitionKey   = 'az'
                            RowKey         = '6.0.0'
                            Title          = 'Az v6.0.0'
                            Link           = 'https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021'
                            TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                            Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                        }
                        return $mock
                    }
                }
                Mock -CommandName Get-TableRowInfo -MockWith $mockInvoke
                Mock -CommandName Set-TableVersionInfo {
                    $PartitionKey | Should -BeExactly 'az'
                    $RowKey | Should -BeExactly '6.3.0'
                } -Verifiable
                Mock -CommandName Set-BlobVersionInfo {
                    $Blob | Should -BeExactly 'az'
                } -Verifiable
                Start-PowerShellAZCheck
                Assert-VerifiableMock
            } #it
            It 'should perform the az preview updates with the correct parameters' {
                $script:mockCalled = 0
                $mockInvoke = {
                    $script:mockCalled++
                    if ($script:mockCalled -eq 1) {
                        $mock = [PSCustomObject]@{
                            PartitionKey   = 'az'
                            RowKey         = '6.0.0'
                            Title          = 'Az v6.0.0'
                            Link           = 'https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021'
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
                    $PartitionKey | Should -BeExactly 'azpreview'
                    $RowKey | Should -BeExactly '6.4.0'
                } -Verifiable
                Mock -CommandName Set-BlobVersionInfo {
                    $Blob | Should -BeExactly 'azpreview'
                } -Verifiable
                Start-PowerShellAZCheck
                Assert-VerifiableMock
            } #it
            It 'should return true if no issues are encountered' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
