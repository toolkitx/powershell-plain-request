
$ModulePath = $PSScriptRoot.Replace('\tool', '')
$OriginalModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
$NewModulePath = $OriginalModulePath.Replace(";$ModulePath", "")
$NewModulePath += ";$ModulePath"
[Environment]::SetEnvironmentVariable("PSModulePath", $NewModulePath)
Write-Host $NewModulePath

$key = [Environment]::GetEnvironmentVariable("PSGalleryAPIKey")

Publish-Module -Name SimpleRequest -NuGetApiKey $key

[Environment]::SetEnvironmentVariable("PSModulePath", $OriginalModulePath)