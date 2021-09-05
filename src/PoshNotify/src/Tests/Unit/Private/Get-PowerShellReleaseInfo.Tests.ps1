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

    # $pwshReleaseInfo | select url,id,tag_name,name,draft,prerelease,created_at,published_at,html_url
    Context 'Get-PowerShellReleaseInfo' {
        BeforeEach {
            $releaseInfo = [System.Collections.ArrayList]@()
            $obj1 = [PSCustomObject]@{
                url          = 'https://api.github.com/repos/PowerShell/PowerShell/releases/47773891'
                id           = '47773891'
                tag_name     = 'v7.1.4'
                name         = 'v7.1.4 Release of PowerShell'
                draft        = 'False'
                prerelease   = 'False'
                created_at   = '08 / 12 / 21 22:17:28'
                published_at = '08 / 12 / 21 22:19:31'
                html_url     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
            }
            $obj2 = [PSCustomObject]@{
                url          = 'https://api.github.com/repos/PowerShell/PowerShell/releases/48290816'
                id           = '48290816'
                tag_name     = 'v7.2.0-preview.9'
                name         = 'v7.2.0-preview.9 Release of PowerShell'
                draft        = 'False'
                prerelease   = 'True'
                created_at   = '08 / 23 / 21 18:14:55'
                published_at = '08 / 23 / 21 18:34:52'
                html_url     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.9'
            }

            $releaseInfo.Add($obj1) | Out-Null
            $releaseInfo.Add($obj2) | Out-Null

            Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                $releaseInfo
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if no release information is returned at all' {
                Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                    $null
                } #endMock
                Get-PowerShellReleaseInfo | Should -BeNullOrEmpty
            } #it
            It 'should return null if the preview version number can not be parsed properly' {
                $releaseInfo2 = [System.Collections.ArrayList]@()
                $obj4 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/PowerShell/PowerShell/releases/47773891'
                    id           = '47773891'
                    tag_name     = 'v7.1.4'
                    name         = 'v7.1.4 Release of PowerShell'
                    draft        = 'False'
                    prerelease   = 'False'
                    created_at   = '08 / 12 / 21 22:17:28'
                    published_at = '08 / 12 / 21 22:19:31'
                    html_url     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                }
                $obj5 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/PowerShell/PowerShell/releases/48290816'
                    id           = '48290816'
                    tag_name     = 'vnotaversionnumber-preview.9'
                    name         = 'vnotaversionnumber-preview.9 Release of PowerShell'
                    draft        = 'False'
                    prerelease   = 'True'
                    created_at   = '08 / 23 / 21 18:14:55'
                    published_at = '08 / 23 / 21 18:34:52'
                    html_url     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.9'
                }

                $releaseInfo2.Add($obj4) | Out-Null
                $releaseInfo2.Add($obj5) | Out-Null

                Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                    $releaseInfo2
                } #endMock
                Get-PowerShellReleaseInfo | Should -BeNullOrEmpty
            } #it
            It 'should return null if the version number can not be parsed properly' {
                $releaseInfo3 = [System.Collections.ArrayList]@()
                $obj6 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/PowerShell/PowerShell/releases/47773891'
                    id           = '47773891'
                    tag_name     = 'vnotaversionnumber'
                    name         = 'vnotaversionnumber Release of PowerShell'
                    draft        = 'False'
                    prerelease   = 'False'
                    created_at   = '08 / 12 / 21 22:17:28'
                    published_at = '08 / 12 / 21 22:19:31'
                    html_url     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                }
                $obj7 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/PowerShell/PowerShell/releases/48290816'
                    id           = '48290816'
                    tag_name     = 'v7.2.0-preview.9'
                    name         = 'v7.2.0-preview.9 Release of PowerShell'
                    draft        = 'False'
                    prerelease   = 'True'
                    created_at   = '08 / 23 / 21 18:14:55'
                    published_at = '08 / 23 / 21 18:34:52'
                    html_url     = 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.9'
                }

                $releaseInfo3.Add($obj6) | Out-Null
                $releaseInfo3.Add($obj7) | Out-Null

                Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                    $releaseInfo3
                } #endMock
                Get-PowerShellReleaseInfo | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should call the Get-GitHubReleaseInfo with the correct repo name' {
                Mock -CommandName Get-GitHubReleaseInfo {
                    $RepositoryName | Should -BeExactly 'PowerShell/PowerShell'
                } -Verifiable
                Get-PowerShellReleaseInfo
                Assert-VerifiableMock
            } #it
            It 'should return expected results if successful' {
                $eval = Get-PowerShellReleaseInfo
                $eval.PwshVersion | Should -BeExactly '7.1.4'
                $eval.PwshTitle | Should -BeExactly 'v7.1.4 Release of PowerShell'
                $eval.PwshLink | Should -BeExactly 'https://github.com/PowerShell/PowerShell/releases/tag/v7.1.4'
                $eval.PwshPreviewVersion | Should -BeExactly '7.2.0'
                $eval.PwshPreviewTitle | Should -BeExactly 'v7.2.0-preview.9 Release of PowerShell'
                $eval.PwshPreviewLink | Should -BeExactly 'https://github.com/PowerShell/PowerShell/releases/tag/v7.2.0-preview.9'
                $eval.PwshPreviewRC | Should -BeExactly '9'
            } #it
        } #context-success
    } #context
} #inModule
