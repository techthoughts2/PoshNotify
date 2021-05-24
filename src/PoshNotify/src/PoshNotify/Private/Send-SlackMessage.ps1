<#
.SYNOPSIS
    Sends a nicely formatted slack message about various PowerShell activities/releases.
.DESCRIPTION
    Sends a pre-formatted slack message about new PowerShell versions and PowerShell posts to the slack webhook contained in the environment variable.
.EXAMPLE
    $slackSplatPreview = @{
        Text        = $powerShellReleaseInfo.PreviewTitle
        Title       = 'New PowerShell Preview Release'
        Link        = $powerShellReleaseInfo.PreviewLink
        MessageType = 'PowerShellVersion'
    }
    Send-SlackMessageVersion @slackSplatPreview

    Sends slack notification advising of version upgrade.
.PARAMETER Text
    Text message to send to slack
.PARAMETER Title
    Title of message to send to slack
.PARAMETER Link
    Link to include in slack button
.PARAMETER MessageType
    Type of message context to send
.OUTPUTS
    None
.NOTES
    Invoke-RestMethod
.LINK
    https://app.slack.com/block-kit-builder
.LINK
    https://api.slack.com/messaging/webhooks#advanced_message_formatting
.COMPONENT
    PoshNotify
#>
function Send-SlackMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Text message to send to slack')]
        [ValidateNotNullOrEmpty()]
        [string]$Text,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Title of message to send to slack')]
        [ValidateNotNullOrEmpty()]
        [string]$Title,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Link to include in slack button')]
        [ValidateNotNullOrEmpty()]
        [string]$Link,
        [Parameter(Mandatory = $true,
            HelpMessage = 'Type of message context to send')]
        [ValidateSet('PowerShellVersion', 'PowerShellBlog', 'PowerShellReddit')]
        [string]$MessageType,
        [Parameter(Mandatory = $false,
            HelpMessage = 'TBD')]
        [ValidateNotNullOrEmpty()]
        [psobject]$RedditObj
    )

    if ($MessageType -eq 'PowerShellVersion' -or $MessageType -eq 'PowerShellBlog') {
        switch ($MessageType) {
            PowerShellVersion {
                $actionText = 'Get this version'
            }
            PowerShellBlog {
                $actionText = 'Visit'
            }
        }
        $body = @"
{
    "blocks": [
        {
            "type": "divider"
        },
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "$Text",
                "emoji": true
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "$Title"
            },
            "accessory": {
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": $actionText,
                    "emoji": true
                },
                "value": "click_me_123",
                "url": "$Link",
                "action_id": "button-action"
            }
        },
        {
            "type": "divider"
        }
    ]
}
"@
    }
    else {
        $post1 = $RedditObj[0].Title
        $url1 = $($RedditObj[0].URL)
        $post2 = $RedditObj[1].Title
        $url2 = $($RedditObj[1].URL)
        $post3 = $RedditObj[2].Title
        $url3 = $($RedditObj[2].URL)
        $post4 = $RedditObj[3].Title
        $url4 = $($RedditObj[3].URL)
        $post5 = $RedditObj[4].Title
        $url5 = $($RedditObj[4].URL)
        $body = @"
{
    "blocks": [
        {
            "type": "divider"
        },
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "PowerShell posts of the week!",
                "emoji": true
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "Here are the top 5 *<https://www.reddit.com/r/PowerShell/|/r/PowerShell>* :reddit: posts for this week :powershell:: \n1. <$url1|$post1>\n2. <$url2|$post2>\n3. <$url3|$post3>\n4. <$url4|$post4>\n5. <$url5|$post5>"
            }
        },
        {
            "type": "divider"
        }
    ]
}
"@
        Write-Verbose -Message $body
    }

    Write-Verbose -Message ('Sending slack message regarding {0}' -f $MessageType)
    $invokeSplat = @{
        Uri         = $env:SLACK_ENDPOINT
        Method      = 'Post'
        Body        = $body
        ContentType = 'application/json'
        ErrorAction = 'Stop'
    }
    try {
        Invoke-RestMethod @invokeSplat | Out-Null
        Write-Verbose -Message 'Slack message SENT!'
    }
    catch {
        Send-TelegramError -ErrorMessage '\\\ Project PoshNotify - Send-SlackMessage to Slack went wrong.'
        Write-Error $_
    }
} #Send-SlackMessage
