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
    Context 'Start-PowerShellAZCheck' {
        function Send-SlackMessage {
        }
        function ConvertTo-Clixml {
        }
        function Out-File {
        }
        BeforeEach {
            Mock -CommandName Get-PowerShellAZReleaseInfo -MockWith {
                [PSCustomObject]@{
                    AZVersion = '6.0.0'
                    AZTitle   = 'Az 6.0.0'
                    AZLink    = 'https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021'
                }
            } #endMock
            Mock -CommandName Get-BlobVersionInfo -MockWith {
                [PSCustomObject]@{
                    AZVersion = '6.0.0'
                    AZTitle   = 'Az 6.0.0'
                    AZLink    = 'https://github.com/Azure/azure-powershell/releases/tag/v6.0.0-May2021'
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
            Mock -CommandName Start-PowerShellAZCheck -MockWith { } #endMock
            It 'Should process by default' {
                Start-PowerShellAZCheck
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 1
            }#it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Start-PowerShellAZCheck }
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Start-PowerShellAZCheck
                }
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Start-PowerShellAZCheck }
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Start-PowerShellAZCheck
                }
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 0
            }#it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Start-PowerShellAZCheck
                Assert-MockCalled Start-PowerShellAZCheck -Scope It -Exactly -Times 1
            }#it
        } #context
        Context 'Error' {
            It 'should return false if no Powershell version information is found' {
                Mock -CommandName Get-PowerShellAZReleaseInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $false
            } #it
            It 'should return false if no version information is found from blob' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Set-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Mock -CommandName Get-PowerShellAZReleaseInfo -MockWith {
                    [PSCustomObject]@{
                        AZVersion = '6.1.0'
                        AZTitle   = 'Az 6.1.0'
                        AZLink    = 'https://github.com/Azure/azure-powershell/releases/tag/v6.1.0-July2021'
                    }
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should not throw if a new version is not discovered' {
                { Start-PowerShellAZCheck } | Should Not Throw
            } #it
            It 'should not send slack messages if a new version is not discovered' {
                Start-PowerShellAZCheck
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 0
            } #it
            It 'should not update the blob if a new version is not discovered' {
                Start-PowerShellAZCheck
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
            } #it
            It 'should not throw if a new version is discovered' {
                Mock -CommandName Get-PowerShellAZReleaseInfo -MockWith {
                    [PSCustomObject]@{
                        AZVersion = '6.1.0'
                        AZTitle   = 'Az 6.1.0'
                        AZLink    = 'https://github.com/Azure/azure-powershell/releases/tag/v6.1.0-July2021'
                    }
                } #endMock
                { Start-PowerShellAZCheck } | Should Not Throw
            } #it
            It 'should send slack messages if a new version is discovered' {
                Mock -CommandName Get-PowerShellAZReleaseInfo -MockWith {
                    [PSCustomObject]@{
                        AZVersion = '6.1.0'
                        AZTitle   = 'Az 6.1.0'
                        AZLink    = 'https://github.com/Azure/azure-powershell/releases/tag/v6.1.0-July2021'
                    }
                } #endMock
                Start-PowerShellAZCheck
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 1
            } #it
            It 'should update the blob if a new version is discovered' {
                Mock -CommandName Get-PowerShellAZReleaseInfo -MockWith {
                    [PSCustomObject]@{
                        AZVersion = '6.1.0'
                        AZTitle   = 'Az 6.1.0'
                        AZLink    = 'https://github.com/Azure/azure-powershell/releases/tag/v6.1.0-July2021'
                    }
                } #endMock
                Start-PowerShellAZCheck
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
            } #it
            It 'should not throw if the blob has never been created before' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                { Start-PowerShellAZCheck } | Should Not Throw
            } #it
            It 'should return true if no issues are encountered' {
                Mock -CommandName Get-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellAZCheck | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
