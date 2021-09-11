BeforeAll {
    #-------------------------------------------------------------------------
    Set-Location -Path $PSScriptRoot
    #-------------------------------------------------------------------------
    $ModuleName = 'PoshNotify'
    $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
    $PathToModule = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psm1")
    #-------------------------------------------------------------------------
}
Describe 'Module Tests' -Tag Unit {
    Context "Module Tests" {
        $script:manifestEval = $null
        It 'Passes Test-ModuleManifest' {
            { $script:manifestEval = Test-ModuleManifest -Path $PathToManifest } | Should -Not -Throw
            $? | Should -BeTrue
        } #manifestTest
        It 'root module PoshNotify.psm1 should exist' {
            $PathToModule | Should -Exist
            $? | Should -BeTrue
        } #psm1Exists
        It 'manifest should contain PoshNotify.psm1' {
            $PathToManifest |
            Should -FileContentMatchExactly "PoshNotify.psm1"
        } #validPSM1
        It 'should have a matching module name in the manifest' {
            $script:manifestEval.Name | Should -BeExactly $ModuleName
        } #name
        It 'should have a valid description in the manifest' {
            $script:manifestEval.Description | Should -Not -BeNullOrEmpty
        } #description
        It 'should have a valid author in the manifest' {
            $script:manifestEval.Author | Should -Not -BeNullOrEmpty
        } #author
        It 'should have a valid version in the manifest' {
            $script:manifestEval.Version -as [Version] | Should -Not -BeNullOrEmpty
        } #version
        It 'should have a valid guid in the manifest' {
            { [guid]::Parse($script:manifestEval.Guid) } | Should -Not -Throw
        } #guid
        It 'should not have any spaces in the tags' {
            foreach ($tag in $script:manifestEval.Tags) {
                $tag | Should -Not -Match '\s'
            }
        } #tagSpaces
    } #context_ModuleTests
} #describe_ModuleTests
