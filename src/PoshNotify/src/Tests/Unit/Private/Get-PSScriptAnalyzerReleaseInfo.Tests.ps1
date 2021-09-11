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

    Context 'Get-PSScriptAnalyzerReleaseInfo' {
        BeforeEach {
            $releaseInfo = [System.Collections.ArrayList]@()
            $obj1 = [PSCustomObject]@{
                url          = 'https://api.github.com/repos/PowerShell/PSScriptAnalyzer/releases/48379568'
                id           = '48379568'
                tag_name     = '1.20.0'
                name         = 'PSScriptAnalyzer v1.20.0'
                draft        = 'False'
                prerelease   = 'False'
                created_at   = '08/23/21 21:54:44'
                published_at = '08/24/21 19:47:27'
                html_url     = 'https://github.com/PowerShell/PSScriptAnalyzer/releases/tag/1.20.0'
            }

            $releaseInfo.Add($obj1) | Out-Null

            Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                $releaseInfo
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if no release information is returned at all' {
                Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                    $null
                } #endMock
                Get-PSScriptAnalyzerReleaseInfo | Should -BeNullOrEmpty
            } #it
            It 'should return null if the version number can not be parsed properly' {
                $releaseInfo3 = [System.Collections.ArrayList]@()
                $obj6 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/PowerShell/PSScriptAnalyzer/releases/48379568'
                    id           = '48379568'
                    tag_name     = 'notaversionnumber'
                    name         = 'PSScriptAnalyzer vnotaversionnumber'
                    draft        = 'False'
                    prerelease   = 'False'
                    created_at   = '08/23/21 21:54:44'
                    published_at = '08/24/21 19:47:27'
                    html_url     = 'https://github.com/PowerShell/PSScriptAnalyzer/releases/tag/1.20.0'
                }

                $releaseInfo3.Add($obj6) | Out-Null

                Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                    $releaseInfo3
                } #endMock
                Get-PSScriptAnalyzerReleaseInfo | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should call the Get-GitHubReleaseInfo with the correct repo name' {
                Mock -CommandName Get-GitHubReleaseInfo {
                    $RepositoryName | Should -BeExactly 'PowerShell/PSScriptAnalyzer'
                } -Verifiable
                Get-PSScriptAnalyzerReleaseInfo
                Assert-VerifiableMock
            } #it
            It 'should return expected results if successful' {
                $eval = Get-PSScriptAnalyzerReleaseInfo
                $eval.PSSAVersion | Should -BeExactly '1.20.0'
                $eval.PSSATitle | Should -BeExactly 'PSScriptAnalyzer v1.20.0'
                $eval.PSSALink | Should -BeExactly 'https://github.com/PowerShell/PSScriptAnalyzer/releases/tag/1.20.0'
            } #it
        } #context-success
    } #context
} #inModule
