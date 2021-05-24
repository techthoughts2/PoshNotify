<#
.SYNOPSIS
    Sends error message to Telegram for notification.
.COMPONENT
    PoshNotify
#>
function Send-TelegramError {
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Original File Path')]
        [string]
        $ErrorMessage
    )
    try {
        Send-TelegramTextMessage -BotToken $env:TOKEN -ChatID $env:CHANNEL -Message $ErrorMessage
    }
    catch {
        Write-Error $_
    }
} #Send-TelegramError
