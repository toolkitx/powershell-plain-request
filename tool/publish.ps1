$ModulePath = $PSScriptRoot.Replace('\tool', '').Replace('/tool', '')

$galleryVersion = (Find-Module -Name SimpleRequest).Version
Write-Host "Gallery: v$galleryVersion"

$key = [Environment]::GetEnvironmentVariable("PSGalleryAPIKey")
$ModulePath = $PSScriptRoot.Replace('\tool', '').Replace('/tool', '')
$OriginalModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
Write-Host "Origin Module Path: $OriginalModulePath"
$NewModulePath = $OriginalModulePath.Replace(":$ModulePath", "")
$NewModulePath += ":$ModulePath"
[Environment]::SetEnvironmentVariable("PSModulePath", $NewModulePath)

Write-Host "New Module Path: $NewModulePath"

$localVersion = (Get-Module -Name SimpleRequest).Version.ToString()
Write-Host "New Version: v$localVersion"

if ($galleryVersion -eq $localVersion) {
    Write-Host "Same version, skip!"
    return;
} else {
    Publish-Module -Name SimpleRequest -NuGetApiKey $key
    $galleryVersion = (Find-Module -Name SimpleRequest).Version
    Write-Host "Current Gallery Published: v$galleryVersion"
}

[Environment]::SetEnvironmentVariable("PSModulePath", $OriginalModulePath)