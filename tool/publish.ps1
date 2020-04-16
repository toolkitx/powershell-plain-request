$ModulePath = $PSScriptRoot.Replace('\tool', '').Replace('/tool', '')
$ModuleName = "SimpleRequest"
$galleryVersion = (Find-Module -Name $ModuleName).Version
Write-Host "===> Gallery: v$galleryVersion"

$ModulePath = $PSScriptRoot.Replace('\tool', '').Replace('/tool', '')
$OriginalModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
Write-Host "===> Origin Module Path: $OriginalModulePath"
$NewModulePath = $OriginalModulePath.Replace(":$ModulePath", "")
$NewModulePath += ":$ModulePath"
[Environment]::SetEnvironmentVariable("PSModulePath", $NewModulePath)

Write-Host "===> New Module Path: $NewModulePath"
$localModule = Import-PowerShellDataFile -Path "$ModulePath/$ModuleName/$ModuleName.psd1"
if ($localModule) {
    $localVersion = $localModule.ModuleVersion.ToString()
    Write-Host "===> New Version: v$localVersion"
}


if ($galleryVersion -eq $localVersion) {
    Write-Host "===> Same version, skip!"
    return;
} else {
    $key = [Environment]::GetEnvironmentVariable("PSGalleryAPIKey")
    Publish-Module -Name $ModuleName -NuGetApiKey $key
    $newGalleryVersion = (Find-Module -Name $ModuleName).Version
    Write-Host "===> Current Gallery Published: v$galleryVersion => v$newGalleryVersion"
}

[Environment]::SetEnvironmentVariable("PSModulePath", $OriginalModulePath)