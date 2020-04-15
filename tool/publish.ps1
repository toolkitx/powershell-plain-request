$ModulePath = $PSScriptRoot.Replace('\tool', '').Replace('/tool', '')

$galleryVersion = (Find-Module -Name SimpleRequest).Version
Write-Host "Gallery: v$galleryVersion"
$ModuleName = "SimpleRequest"
Get-Module -Name $ModuleName | Remove-Module
Import-Module -Name "$ModulePath/$ModuleName"
$localVersion = (Get-Module -Name $ModuleName).Version.ToString()
Write-Host "New Version: v$localVersion"
if ($galleryVersion -eq $localVersion) {
    Write-Host "Same version, skip!"
    return;
}

$key = [Environment]::GetEnvironmentVariable("PSGalleryAPIKey")

Publish-Module -Name SimpleRequest -NuGetApiKey $key
Write-Host "Published: v$localVersion"