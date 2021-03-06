# This is a locally sourced Imports file for local development.
# It can be imported by the psm1 in local development to add script level variables.
# It will merged in the build process. This is for local development only.

# region script variables
# $script:resourcePath = "$PSScriptRoot\Resources"
$script:psBlogData = 'pwshblog'
$script:pwsh = 'pwsh'
$script:pwshPreview = 'pwshpreview'
$script:az = 'az'
$script:azPreview = 'azpreview'
$script:pssa = 'pssa'
$script:versionRegex = '\d+(?:\.\d+)+'

# $pwshReleaseInfo | select url,id,tag_name,name,draft,prerelease,created_at,published_at,html_url
# $pwshReleaseInfo | select name,draft,prerelease