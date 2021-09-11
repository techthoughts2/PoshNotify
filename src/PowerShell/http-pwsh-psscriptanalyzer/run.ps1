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

Write-Information 'Starting PSScriptAnalyzerCheck checks...'

Import-Module PoshNotify # custom module sourced from Modules folder
$result = Start-PSScriptAnalyzerCheck -Verbose

if ($result -eq $true) {
    $status = [HttpStatusCode]::OK
}
else {
    $status = [HttpStatusCode]::SeeOther
}

Write-Information '####################RESULTS##########################'
Write-Information "Status: `n $status"
Write-Information "Body: `n $body"
Write-Information '#####################################################'

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $status
        Body       = $result
    })
