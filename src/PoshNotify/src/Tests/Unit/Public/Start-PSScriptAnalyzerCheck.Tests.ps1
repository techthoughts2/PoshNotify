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
    Context 'Start-PSScriptAnalyzerCheck' {
        BeforeEach {
            function Send-SlackMessage {
            }
            function ConvertTo-Clixml {
            }
            function Out-File {
            }
            Mock -CommandName Get-PSScriptAnalyzerReleaseInfo -MockWith {
                [PSCustomObject]@{
                    PSSAVersion = '1.20.0'
                    PSSATitle   = 'PSScriptAnalyzer v1.20.0'
                    PSSALink    = 'https://github.com/PowerShell/PSScriptAnalyzer/releases/tag/1.20.0'
                }
            } #endMock
            Mock -CommandName Get-TableRowInfo -MockWith {
                [PSCustomObject]@{
                    PartitionKey = 'pssa'
                    RowKey       = '1.20.0'
                    Title        = 'PSScriptAnalyzer v1.20.0'
                    Link         = 'https://github.com/PowerShell/PSScriptAnalyzer/releases/tag/1.20.0'
                }
            } #endMock
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
                Mock -CommandName Start-PSScriptAnalyzerCheck -MockWith { } #endMock
            } #beforeEach
            It 'Should process by default' {
                Start-PSScriptAnalyzerCheck
                Assert-MockCalled Start-PSScriptAnalyzerCheck -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Start-PSScriptAnalyzerCheck }
                Assert-MockCalled Start-PSScriptAnalyzerCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Start-PSScriptAnalyzerCheck
                }
                Assert-MockCalled Start-PSScriptAnalyzerCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Start-PSScriptAnalyzerCheck }
                Assert-MockCalled Start-PSScriptAnalyzerCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Start-PSScriptAnalyzerCheck
                }
                Assert-MockCalled Start-PSScriptAnalyzerCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Start-PSScriptAnalyzerCheck
                Assert-MockCalled Start-PSScriptAnalyzerCheck -Scope It -Exactly -Times 1
            } #it
        } #context
        Context 'Error' {
            It 'should return false if no PSScriptAnalyzer version information is found' {
                Mock -CommandName Get-PSScriptAnalyzerReleaseInfo -MockWith {
                    $null
                } #endMock
                Start-PSScriptAnalyzerCheck | Should -BeExactly $false
            } #it
            It 'should return false if an issue is encountered getting table information' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $false
                } #endMock
                Start-PSScriptAnalyzerCheck | Should -BeExactly $false
            } #it
            # It 'should return false if no version information is found from blob' {
            #     Mock -CommandName Get-BlobVersionInfo -MockWith {
            #         $null
            #     } #endMock
            #     Start-PSScriptAnalyzerCheck | Should -BeExactly $false
            # } #it
            It 'should return false if table is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-TableVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PSScriptAnalyzerCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PSScriptAnalyzerCheck | Should -BeExactly $false
            } #it
            It 'should return false if table is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-TableVersionInfo -MockWith {
                    $false
                } #endMock

                Start-PSScriptAnalyzerCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PSScriptAnalyzerCheck | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should not update anything or send messages if no new versions are found' {
                Start-PSScriptAnalyzerCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 0
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 0
            } #it
            It 'should only update and send 1 message if new version is found' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Start-PSScriptAnalyzerCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 1
            } #it
            It 'should perform the updates for PSScriptAnalyzer version with the correct parameters' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-TableVersionInfo {
                    $PartitionKey | Should -BeExactly 'pssa'
                    $RowKey | Should -BeExactly '1.20.0'
                } -Verifiable
                Mock -CommandName Set-BlobVersionInfo {
                    $Blob | Should -BeExactly 'pssa'
                } -Verifiable
                Start-PSScriptAnalyzerCheck
                Assert-VerifiableMock
            } #it
            It 'should return true if no issues are encountered' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Start-PSScriptAnalyzerCheck | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
