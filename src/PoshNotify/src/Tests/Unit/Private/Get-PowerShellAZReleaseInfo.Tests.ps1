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
    #-------------------------------------------------------------------------
    BeforeAll {
        $WarningPreference = 'SilentlyContinue'
        $ErrorActionPreference = 'SilentlyContinue'
    }
    function Send-TelegramError {
    }

    Context 'Get-PowerShellAZReleaseInfo' {
        BeforeEach {
            $releaseInfo = [System.Collections.ArrayList]@()
            $obj1 = [PSCustomObject]@{
                url          = 'https://api.github.com/repos/Azure/azure-powershell/releases/48962155'
                id           = '48962155'
                tag_name     = 'v6.4.0-September2021'
                name         = 'Az 6.4.0'
                draft        = 'False'
                prerelease   = 'True'
                created_at   = '09 / 03 / 21 12:59:52'
                published_at = '09 / 03 / 21 13:05:55'
                html_url     = 'https://github.com/Azure/azure-powershell/releases/tag/v6.4.0-September2021'
            }
            $obj2 = [PSCustomObject]@{
                url          = 'https://api.github.com/repos/Azure/azure-powershell/releases/47034833'
                id           = '47034833'
                tag_name     = 'v6.3.0-August2021'
                name         = 'Az v6.3.0'
                draft        = 'False'
                prerelease   = 'False'
                created_at   = '07/29/21 04:49:30'
                published_at = '07/30/21 09:59:23'
                html_url     = 'https://github.com/Azure/azure-powershell/releases/tag/v6.3.0-August2021'
            }
            $obj3 = [PSCustomObject]@{
                url          = 'https://api.github.com/repos/Azure/azure-powershell/releases/39107206'
                id           = '39107206'
                tag_name     = 'Az.Tools.Predictor-0.2.0'
                name         = 'Az.Tools.Predictor 0.2.0'
                draft        = 'False'
                prerelease   = 'True'
                created_at   = '03/02/21 09:10:11'
                published_at = '03/02/21 10:14:44'
                html_url     = 'https://github.com/Azure/azure-powershell/releases/tag/Az.Tools.Predictor-0.2.0'
            }

            $releaseInfo.Add($obj1) | Out-Null
            $releaseInfo.Add($obj2) | Out-Null
            $releaseInfo.Add($obj3) | Out-Null

            Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                $releaseInfo
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if no release information is returned at all' {
                Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                    $null
                } #endMock
                Get-PowerShellAZReleaseInfo | Should -BeNullOrEmpty
            } #it
            It 'should return null if the preview version number can not be parsed properly' {
                $releaseInfo2 = [System.Collections.ArrayList]@()
                $obj4 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/Azure/azure-powershell/releases/48962155'
                    id           = '48962155'
                    tag_name     = 'vnotaversionnumber-September2021'
                    name         = 'Az notaversionnumber'
                    draft        = 'False'
                    prerelease   = 'True'
                    created_at   = '09 / 03 / 21 12:59:52'
                    published_at = '09 / 03 / 21 13:05:55'
                    html_url     = 'https://github.com/Azure/azure-powershell/releases/tag/v6.4.0-September2021'
                }
                $obj5 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/Azure/azure-powershell/releases/47034833'
                    id           = '47034833'
                    tag_name     = 'v6.3.0-August2021'
                    name         = 'Az v6.3.0'
                    draft        = 'False'
                    prerelease   = 'False'
                    created_at   = '07/29/21 04:49:30'
                    published_at = '07/30/21 09:59:23'
                    html_url     = 'https://github.com/Azure/azure-powershell/releases/tag/v6.3.0-August2021'
                }

                $releaseInfo2.Add($obj4) | Out-Null
                $releaseInfo2.Add($obj5) | Out-Null

                Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                    $releaseInfo2
                } #endMock
                Get-PowerShellAZReleaseInfo | Should -BeNullOrEmpty
            } #it
            It 'should return null if the version number can not be parsed properly' {
                $releaseInfo3 = [System.Collections.ArrayList]@()
                $obj6 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/Azure/azure-powershell/releases/48962155'
                    id           = '48962155'
                    tag_name     = 'v6.4.0-September2021'
                    name         = 'Az 6.4.0'
                    draft        = 'False'
                    prerelease   = 'True'
                    created_at   = '09 / 03 / 21 12:59:52'
                    published_at = '09 / 03 / 21 13:05:55'
                    html_url     = 'https://github.com/Azure/azure-powershell/releases/tag/v6.4.0-September2021'
                }
                $obj7 = [PSCustomObject]@{
                    url          = 'https://api.github.com/repos/Azure/azure-powershell/releases/47034833'
                    id           = '47034833'
                    tag_name     = 'vnotaversionnumber-August2021'
                    name         = 'Az vnotaversionnumber'
                    draft        = 'False'
                    prerelease   = 'False'
                    created_at   = '07/29/21 04:49:30'
                    published_at = '07/30/21 09:59:23'
                    html_url     = 'https://github.com/Azure/azure-powershell/releases/tag/v6.3.0-August2021'
                }

                $releaseInfo3.Add($obj6) | Out-Null
                $releaseInfo3.Add($obj7) | Out-Null

                Mock -CommandName Get-GitHubReleaseInfo -MockWith {
                    $releaseInfo3
                } #endMock
                Get-PowerShellAZReleaseInfo | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should call the Get-GitHubReleaseInfo with the correct repo name' {
                Mock -CommandName Get-GitHubReleaseInfo {
                    $RepositoryName | Should -BeExactly 'Azure/azure-powershell'
                } -Verifiable
                Get-PowerShellAZReleaseInfo
                Assert-VerifiableMock
            } #it
            It 'should return expected results if successful' {
                $eval = Get-PowerShellAZReleaseInfo
                $eval.AZVersion | Should -BeExactly '6.3.0'
                $eval.AZTitle | Should -BeExactly 'Az v6.3.0'
                $eval.AZLink | Should -BeExactly 'https://github.com/Azure/azure-powershell/releases/tag/v6.3.0-August2021'
                $eval.AZPreviewVersion | Should -BeExactly '6.4.0'
                $eval.AZPreviewTitle | Should -BeExactly 'Az 6.4.0'
                $eval.AZPreviewLink | Should -BeExactly 'https://github.com/Azure/azure-powershell/releases/tag/v6.4.0-September2021'
            } #it
        } #context-success
    } #context
} #inModule
