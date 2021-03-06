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
    function Send-TelegramError {
    }
    Context 'Get-PowerShellBlogInfo' {
        BeforeEach {
            Mock -CommandName Invoke-RestMethod -MockWith {
                @(
                    [PSCustomObject]@{
                        title       = 'Announcing PlatyPS 2.0.0-Preview1'
                        link        = 'https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/'
                        comments    = '{https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/#respond, 0}'
                        creator     = 'creator'
                        pubDate     = 'Thu, 20 May 2021 19:08:32 +0000'
                        category    = '{category, category}'
                        guid        = @{
                            isPermaLink = 'false'
                            '#text'     = 'https://devblogs.microsoft.com/powershell/?p=19019'
                        }
                        description = 'description'
                        encoded     = 'encoded'
                        commentRss  = 'https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/feed/'
                    }
                    [PSCustomObject]@{
                        title       = 'PSArm Experiment Update'
                        link        = 'https://devblogs.microsoft.com/powershell/psarm-experiment-update/'
                        comments    = '{https://devblogs.microsoft.com/powershell/psarm-experiment-update/#comments, 1}'
                        creator     = 'creator'
                        pubDate     = 'Wed, 11 Aug 2021 23:47:32 +0000'
                        category    = '{category, category, category}'
                        guid        = @{
                            isPermaLink = 'false'
                            '#text'     = 'https://devblogs.microsoft.com/powershell/?p=19144'
                        }
                        description = 'description'
                        encoded     = 'encoded'
                        commentRss  = 'https://devblogs.microsoft.com/powershell/psarm-experiment-update/feed/'
                    }
                )
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if an error is encountered getting PowerShell blog rss info' {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    throw 'FakeError'
                } #endMock
                Get-PowerShellBlogInfo | Should -BeNullOrEmpty
            } #it
            It 'should return null if the returned data does not have valid GUID information' {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    @(
                        [PSCustomObject]@{
                            title       = 'Announcing PlatyPS 2.0.0-Preview1'
                            link        = 'https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/'
                            comments    = '{https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/#respond, 0}'
                            creator     = 'creator'
                            pubDate     = 'Thu, 20 May 2021 19:08:32 +0000'
                            category    = '{category, category}'
                            guid        = @{
                                isPermaLink = 'false'
                                '#text'     = 'https://devblogs.microsoft.com/powershell/?p=19019'
                            }
                            description = 'description'
                            encoded     = 'encoded'
                            commentRss  = 'https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/feed/'
                        }
                        [PSCustomObject]@{
                            title       = 'PSArm Experiment Update'
                            link        = 'https://devblogs.microsoft.com/powershell/psarm-experiment-update/'
                            comments    = '{https://devblogs.microsoft.com/powershell/psarm-experiment-update/#comments, 1}'
                            creator     = 'creator'
                            pubDate     = 'Wed, 11 Aug 2021 23:47:32 +0000'
                            category    = '{category, category, category}'
                            guid        = @{
                                isPermaLink = 'false'
                                '#text'     = 'https://unexpectedurl.com'
                            }
                            description = 'description'
                            encoded     = 'encoded'
                            commentRss  = 'https://devblogs.microsoft.com/powershell/psarm-experiment-update/feed/'
                        }
                    )
                } #endMock
                Get-PowerShellBlogInfo | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should return expected results if successful' {
                $eval = Get-PowerShellBlogInfo
                $eval.Count | Should -BeExactly 2
                $eval[0].GUID | Should -BeExactly '19019'
                $eval[0].Title | Should -BeExactly 'Announcing PlatyPS 2.0.0-Preview1'
                $eval[0].Link | Should -BeExactly 'https://devblogs.microsoft.com/powershell/announcing-platyps-2-0-0-preview1/'
            } #it
        } #context-success
    } #context
} #inModule
