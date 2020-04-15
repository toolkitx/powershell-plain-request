
$ModulePath = Split-Path -Path $PSScriptRoot -Parent
$ModuleName = Split-Path -Path $ModulePath -Leaf

# Make sure one or multiple versions of the module are not loaded
Get-Module -Name $ModuleName | Remove-Module

# Import the module and store the information about the module
Import-Module -Name "$ModulePath\$ModuleName.psd1" -PassThru

$ModulePath = $PSScriptRoot.Replace('\tool', '')
$OriginalModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
$NewModulePath = $OriginalModulePath.Replace(";$ModulePath", "")
$NewModulePath += ";$ModulePath"
[Environment]::SetEnvironmentVariable("PSModulePath", $NewModulePath)
Write-Host $NewModulePath

$key = [Environment]::GetEnvironmentVariable("PSGalleryAPIKey")

Publish-Module -Name SimpleRequest -NuGetApiKey $key

[Environment]::SetEnvironmentVariable("PSModulePath", $OriginalModulePath)