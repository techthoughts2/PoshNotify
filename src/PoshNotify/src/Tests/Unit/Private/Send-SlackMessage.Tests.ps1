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
    function Send-TelegramError {
    }
    $redditInfo = [System.Collections.ArrayList]@()
    $obj1 = [PSCustomObject]@{
        Title = 'Proud noob moment'
        URL   = 'https://www.reddit.com/r/PowerShell/comment'
    }
    $obj2 = [PSCustomObject]@{
        Title = 'Network Troubleshooting w/ PowerShell'
        URL   = 'https://youtu.be/s-Ba4chiNh4'
    }
    $obj3 = [PSCustomObject]@{
        Title = 'Audit Office 365 External Sharing Activities - Never Allow the Resources Fall into Wrong Hands'
        URL   = 'https://www.reddit.com/r/Office365/'
    }
    $obj4 = [PSCustomObject]@{
        Title = 'IE11 desktop app retirement - June 15, 2022'
        URL   = 'https://www.reddit.com/r/PowerShell/comment'
    }
    $obj5 = [PSCustomObject]@{
        Title = 'I like making dumb little games in PowerShell. My latest is Hangman. Clues sourced from Wheel of Fortune.'
        URL   = 'https://www.reddit.com/r/PowerShell/comment'
    }
    $redditInfo.Add($obj1) | Out-Null
    $redditInfo.Add($obj2) | Out-Null
    $redditInfo.Add($obj3) | Out-Null
    $redditInfo.Add($obj4) | Out-Null
    $redditInfo.Add($obj5) | Out-Null

    Context 'Send-SlackMessage' {
        $env:SLACK_ENDPOINT = 'fake'
        $text = 'This is a test'
        $title = 'New PowerShell!'
        $Link = 'alink'
        BeforeEach {
            Mock -CommandName Invoke-RestMethod -MockWith {
                'ok'
            } #endMock
        } #beforeeach
        Context 'Error' {
            It 'should not throw if a message is encountered sending the slack message' {
                Mock -CommandName Invoke-RestMethod -MockWith {
                    throw 'FakeError'
                } #endMock
                { Send-SlackMessage -Text $text -Title $title -Link $Link -MessageType 'PowerShellVersion' } | Should Not Throw
            } #it
        } #context-error
        Context 'Success' {
            It 'should return null if successful and PowerShellVersion is specifed' {
                # { Send-SlackMessage -Text $text -Title $title -Link $Link } | Should -Not Throw
                Send-SlackMessage -Text $text -Title $title -Link $Link -MessageType 'PowerShellVersion' | Should -BeNullOrEmpty
            } #it
            It 'should return null if successful and PowerShellBlog is specifed' {
                # { Send-SlackMessage -Text $text -Title $title -Link $Link } | Should -Not Throw
                Send-SlackMessage -Text $text -Title $title -Link $Link -MessageType 'PowerShellBlog' | Should -BeNullOrEmpty
            } #it
            It 'should return null if successful and PowerShellReddit is specifed' {
                # { Send-SlackMessage -Text $text -Title $title -Link $Link } | Should -Not Throw
                Send-SlackMessage -Text $text -Title $title -Link $Link -MessageType 'PowerShellReddit' -RedditObj $redditInfo | Should -BeNullOrEmpty
            } #it
        } #context-success
    } #context
} #inModule
