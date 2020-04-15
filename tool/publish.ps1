$ModulePath = $PSScriptRoot.Replace('\tool', '').Replace('/tool', '')

$galleryVersion = (Find-Module -Name SimpleRequest).Version
Write-Host "Gallery: v$galleryVersion"
$ModuleName = "SimpleRequest"
Get-Module -Name $ModuleName | Remove-Module

$ModuleInstallPath = "$ModulePath/$ModuleName"

Write-Host $ModuleInstallPath

Import-Module -Name $ModuleInstallPath -Scope Global

$localVersion = (Get-Module -Name $ModuleName).Version.ToString()
Write-Host "New Version: v$localVersion"
if ($galleryVersion -eq $localVersion) {
    Write-Host "Same version, skip!"
    return;
}

$key = [Environment]::GetEnvironmentVariable("PSGalleryAPIKey")

Publish-Module -Name SimpleRequest -NuGetApiKey $key
Write-Host "Published: v$localVersion"

# $ModulePath = $PSScriptRoot.Replace('\tool', '').Replace('/tool', '')
# $OriginalModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
# $NewModulePath = $OriginalModulePath.Replace(";$ModulePath", "")
# $NewModulePath += ";$ModulePath"
# [Environment]::SetEnvironmentVariable("PSModulePath", $NewModulePath)
# Write-Host $NewModulePath

# Publish-Module -Name SimpleRequest -NuGetApiKey test

# [Environment]::SetEnvironmentVariable("PSModulePath", $OriginalModulePath)