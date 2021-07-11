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
    $message = '\\\ Project PoshNotify - {0} - {1}' -f $env:STAGE, $ErrorMessage
    try {
        Send-TelegramTextMessage -BotToken $env:TOKEN -ChatID $env:CHANNEL -Message $message
    }
    catch {
        Write-Error $_
    }
} #Send-TelegramError
