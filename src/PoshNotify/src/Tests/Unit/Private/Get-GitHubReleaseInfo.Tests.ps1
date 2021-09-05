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

    Context 'Get-GitHubReleaseInfo' {
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

            Mock -CommandName Invoke-RestMethod -MockWith {
                $releaseInfo
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should return null if an error is encountered getting PowerShell Github data' {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    throw 'FakeError'
                } #endMock
                Get-GitHubReleaseInfo -RepositoryName 'Azure/azure-powershell' | Should -BeNullOrEmpty
            } #it
        } #context-error
        Context 'Success' {
            It 'should call the API with the expected parameters' {
                Mock -CommandName Invoke-RestMethod {
                    $Uri | Should -BeExactly 'https://api.github.com/repos/Azure/azure-powershell/releases'
                    $ContentType | Should -BeExactly 'application/json'
                    $ErrorAction | Should -BeExactly 'Stop'
                } -Verifiable
                Get-GitHubReleaseInfo -RepositoryName 'Azure/azure-powershell'
                Assert-VerifiableMock
            } #it
            It 'should return expected results if successful' {
                $eval = Get-GitHubReleaseInfo -RepositoryName 'Azure/azure-powershell'
                $current = $eval | Where-Object { $_.prerelease -eq $false }
                $current.name         | Should -BeExactly 'Az v6.3.0'
                $current.url          | Should -BeExactly 'https://api.github.com/repos/Azure/azure-powershell/releases/47034833'
                $current.id           | Should -BeExactly '47034833'
                $current.tag_name     | Should -BeExactly 'v6.3.0-August2021'
                $current.name         | Should -BeExactly 'Az v6.3.0'
                $current.draft        | Should -BeExactly 'False'
                $current.prerelease   | Should -BeExactly 'False'
                $current.created_at   | Should -BeExactly '07/29/21 04:49:30'
                $current.published_at | Should -BeExactly '07/30/21 09:59:23'
            } #it
        } #context-success
    } #context
} #inModule
