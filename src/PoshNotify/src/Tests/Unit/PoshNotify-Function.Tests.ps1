#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'PoshNotify'
$PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
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
    Describe 'PoshNotify Private Function Tests' -Tag Unit {
        Context 'FunctionName' {
            <#
            It 'should ...' {

            } #it
            #>
        } #context_FunctionName
    } #describe_PrivateFunctions
    Describe 'PoshNotify Public Function Tests' -Tag Unit {
        Context 'FunctionName' {
            <#
                It 'should ...' {

                } #it
                #>
        } #context_FunctionName
    } #describe_testFunctions
} #inModule
