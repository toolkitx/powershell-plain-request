$scriptRoot = $PSScriptRoot + '\Public'

Get-ChildItem $scriptRoot *.ps1 | ForEach-Object {
    Import-Module $_.FullName
}