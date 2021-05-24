using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
# Write-Host "PowerShell HTTP trigger function processed a request."

<#
This is how the request comes in:
Body    :
Headers : {}
Method  :
Url     :
Params  : {}
Query   : {}
RawBody :

input.Http.Headers.Add(key, value);
input.Http.Params.Add(key, value);
input.Http.Query.Add(key, value);
#>

Write-Information 'Hi - I hope you are having a great day!'
Write-Information '#####################################################'
Write-Information '######################INPUT##########################'
Write-Information "Request Body: `n $($Request.Body)"

$headersStr = $Request.Headers | Out-String
Write-Information "Headers: `n $headersStr"
# Write-Information "Request Headers Count: `n $($Request.Headers.Count)"
# Write-Information "Request Headers Keys: `n $($Request.Headers.Keys)"
# Write-Information "Request Headers Values: `n $($Request.Headers.Values)"

Write-Information "Request Method: `n $($Request.Method)"

Write-Information "Request Url: `n $($Request.Url)"

$paramsStr = $Request.Params | Out-String
Write-Information "Params: `n $paramsStr"
# Write-Information "Request Params Count: `n $($Request.Params.Count)"
# Write-Information "Request Params Keys: `n $($Request.Params.Keys)"
# Write-Information "Request Params Values: `n $($Request.Params.Values)"

$queryStr = $Request.Query | Out-String
Write-Information "Query: `n $queryStr"
# Write-Information "Request Query Count: `n $($Request.Query.Count)"
# Write-Information "Request Query Keys: `n $($Request.Query.Keys)"
# Write-Information "Request Query Values: `n $($Request.Query.Values)"

Write-Information "Request RawBody: `n $($Request.RawBody)"

# Write-Information "Request TriggerMetadata : `n $($TriggerMetadata.sys)"
$metaStr = $TriggerMetadata | Out-String
Write-Information "TriggerMetadata: `n $metaStr"
Write-Information '#####################################################'
Write-Information '#####################################################'

Write-Information 'Starting telegram send...'
if ((($Request.Body | Get-Member)[0].TypeName) -eq 'System.Collections.Hashtable') {
    Write-Information 'JSON input detected'
    $message = @"
``````
$($Request.RawBody)
``````
"@

}
else {
    $message = $Request.Body
}

try {
    $telegramSplat = @{
        ChatID      = $env:CHANNEL
        BotToken    = $env:TOKEN
        Message     = "$($message)"
        ParseMode   = 'MarkdownV2'
        ErrorAction = 'Stop'
    }
    $tResults = Send-TelegramTextMessage @telegramSplat
    $status = [HttpStatusCode]::OK
    $body = $tResults | ConvertTo-Json
}
catch {
    # $body = ConvertTo-Json @{
    #     Status = [HttpStatusCode]::InternalServerError
    #     Body = $_.Exception.Message
    # }
    $status = [HttpStatusCode]::InternalServerError
    $body = $_.Exception.Message
}


# Interact with query parameters or the body of the request.
# $name = $Request.Query.Name
# if (-not $name) {
#     $name = $Request.Body.Name
# }

# $body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

# if ($name) {
#     $body = "Hello, $name. This HTTP triggered function executed successfully."
# }

Write-Information '####################RESULTS##########################'
Write-Information "Status: `n $status"
Write-Information "Body: `n $body"
Write-Information '#####################################################'

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $status
        Body       = $body
    })
