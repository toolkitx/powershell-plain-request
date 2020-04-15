
$ModulePath = $PSScriptRoot.Replace('\tool', '')
$OriginalModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
$NewModulePath = $OriginalModulePath.Replace(";$ModulePath", "")
$NewModulePath += ";$ModulePath"
[Environment]::SetEnvironmentVariable("PSModulePath", $NewModulePath)
Write-Host $NewModulePath

Publish-Module -Name SimpleRequest -NuGetApiKey oy2ej5vch5wboiesqryqhffdtsk5y64ejhuers6xkauze4

[Environment]::SetEnvironmentVariable("PSModulePath", $OriginalModulePath)