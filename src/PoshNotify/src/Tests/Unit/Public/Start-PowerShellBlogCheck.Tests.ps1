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
    Context 'Start-PowerShellBlogCheck' {
        function Send-SlackMessage {
        }
        function ConvertTo-Clixml {
        }
        function Out-File {
        }
        BeforeEach {
            Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                @(
                    [PSCustomObject]@{
                        GUID    = '19144'
                        title   = 'PSArm Experiment Update'
                        link    = 'https://devblogs.microsoft.com/powershell/psarm-experiment-update/'
                        pubDate = 'Wed, 11 Aug 2021 23:47:32 +0000'
                    },
                    [PSCustomObject]@{
                        GUID    = '19114'
                        title   = 'PowerShellGet 3.0 Preview 11 Release'
                        link    = 'https://devblogs.microsoft.com/powershell/powershellget-3-0-preview-11-release/'
                        pubDate = 'Mon, 09 Aug 2021 22:15:47 +0000'
                    }
                )
            } #endMock
            Mock -CommandName Get-TableRowInfo -MockWith {
                [PSCustomObject]@{
                    PartitionKey   = 'pwshblog'
                    RowKey         = '19144'
                    Title          = 'PSArm Experiment Update'
                    Link           = 'https://devblogs.microsoft.com/powershell/psarm-experiment-update/'
                    TableTimestamp = '08 / 28 / 21 22:55:26 - 05:00'
                    Etag           = 'W / "datetime2021-08-29T03%3A55%3A26.2954648Z"'
                }
            } #endMock
            # Mock -CommandName Get-BlobVersionInfo -MockWith {
            #     [PSCustomObject]@{
            #         Title = 'Announcing PlatyPS 2.0.0-Preview1'
            #         Link  = 'https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/'
            #         Date  = 'Thu, 20 May 2021 19:08:32 +0000'
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
                Mock -CommandName Start-PowerShellBlogCheck -MockWith { } #endMock
            } #beforeEach
            It 'Should process by default' {
                Start-PowerShellBlogCheck
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { Start-PowerShellBlogCheck }
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Medium'
                    Start-PowerShellBlogCheck
                }
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { Start-PowerShellBlogCheck }
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    Start-PowerShellBlogCheck
                }
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                Start-PowerShellBlogCheck
                Assert-MockCalled Start-PowerShellBlogCheck -Scope It -Exactly -Times 1
            } #it
        } #context
        Context 'Error' {
            It 'should return false if no Powershell blog information is found' {
                Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellBlogCheck | Should -BeExactly $false
            } #it
            It 'should return false if an issue is encountered getting table information' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $false
                } #endMock

                Start-PowerShellBlogCheck | Should -BeExactly $false
            } #it
            It 'should return false if table is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-TableVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellBlogCheck | Should -BeExactly $false
            } #it
            It 'should return false if blob is not properly updated' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-BlobVersionInfo -MockWith {
                    $false
                } #endMock
                Start-PowerShellBlogCheck | Should -BeExactly $false
            } #it
        } #context-error
        Context 'Success' {
            It 'should not update anything or send messages if no new posts are found' {
                Start-PowerShellBlogCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 0
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 0
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 0
            } #it
            It 'should process updates for all new posts' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock

                Start-PowerShellBlogCheck
                Assert-MockCalled Set-TableVersionInfo -Scope It -Exactly -Times 2
                Assert-MockCalled Set-BlobVersionInfo -Scope It -Exactly -Times 1
                Assert-MockCalled Send-SlackMessage -Scope It -Exactly -Times 2
            } #it
            It 'should perform the updates for PowerShell posts with the correct parameters' {
                Mock -CommandName Get-PowerShellBlogInfo -MockWith {
                    [PSCustomObject]@{
                        GUID    = '19144'
                        title   = 'PSArm Experiment Update'
                        link    = 'https://devblogs.microsoft.com/powershell/psarm-experiment-update/'
                        pubDate = 'Wed, 11 Aug 2021 23:47:32 +0000'
                    }
                } #endMock
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Mock -CommandName Set-TableVersionInfo {
                    $PartitionKey | Should -BeExactly 'pwshblog'
                    $RowKey | Should -BeExactly '19144'
                } -Verifiable
                Mock -CommandName Set-BlobVersionInfo {
                    $Blob | Should -BeExactly 'pwshblog'
                } -Verifiable
                Start-PowerShellBlogCheck
                Assert-VerifiableMock
            } #it
            It 'should return true if no issues are encountered' {
                Mock -CommandName Get-TableRowInfo -MockWith {
                    $null
                } #endMock
                Start-PowerShellBlogCheck | Should -BeExactly $true
            } #it
        } #context-success
    } #context
} #inModule
