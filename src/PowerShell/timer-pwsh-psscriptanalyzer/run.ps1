# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PSScriptAnalyzer timer is running late!"
}

# Write an information log with the current time.
Write-Host "PSScriptAnalyzer timer trigger function ran! TIME: $currentUTCtime"

Import-Module PoshNotify # custom module sourced from Modules folder
$result = Start-PSScriptAnalyzerCheck -Verbose

return $result