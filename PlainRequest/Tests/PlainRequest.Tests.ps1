$ModulePath = Split-Path -Path $PSScriptRoot -Parent
$ModuleName = Split-Path -Path $ModulePath -Leaf

# Make sure one or multiple versions of the module are not loaded
Get-Module -Name $ModuleName | Remove-Module

# Import the module and store the information about the module
$ModuleInformation = Import-Module -Name "$ModulePath\$ModuleName.psd1" -PassThru
$ModuleInformation | Format-List

# Get the functions present in the Manifest
$ExportedFunctions = $ModuleInformation.ExportedFunctions.Values.Name

# Get the functions present in the Public folder
$PS1Functions = Get-ChildItem -Path "$ModulePath\Public\*.ps1"

Describe "$ModuleName Module - Testing Manifest File (.psd1)" {
    Context "Manifest" {
        It "Should contain RootModule" {
            $ModuleInformation.RootModule | Should Not BeNullOrEmpty
        }

        It "Should contain ModuleVersion" {
            $ModuleInformation.Version | Should Not BeNullOrEmpty
        }

        It "Should contain GUID" {
            $ModuleInformation.Guid | Should Not BeNullOrEmpty
        }

        It "Should contain Author" {
            $ModuleInformation.Author | Should Not BeNullOrEmpty
        }

        It "Should contain Description" {
            $ModuleInformation.Description | Should Not BeNullOrEmpty
        }

        It "Compare the count of Function Exported and the PS1 files found" {
            $status = $ExportedFunctions.Count -eq $PS1Functions.Count
            $status | Should Be $true
        }

        It "Compare the missing function" {
            If ($ExportedFunctions.count -ne $PS1Functions.count) {
                $Compare = Compare-Object -ReferenceObject $ExportedFunctions -DifferenceObject $PS1Functions.Basename
                $Compare.InputObject -Join ',' | Should BeNullOrEmpty
            }
        }

        It "Should send GET request" {
            $Data = @{
                "TokenUrl"     = 111
                "ClientSecret" = "222"
                "ClientId"     = "333"
                "AuthResource" = "444"
                "Username"     = "User1"
                "Password"     = "Password"
                "Id"           = 99
                "Price"        = 0.99
                "Value"        = "Content"
            }
            
            $GetSample = "
            Get https://httpbin.org/ip

            Content-Type: application/json
            Authorization: Basic {Username} {Password}

            "

            $Response = Invoke-PlainRequest -Syntax $GetSample -Context $Data
            $Response | Should Not BeNullOrEmpty
        }

        It "Should send POST request" {
            $Data = @{
                "TokenUrl"     = 111
                "ClientSecret" = "222"
                "ClientId"     = "333"
                "AuthResource" = "444"
                "Username"     = "User1"
                "Password"     = "Password"
                "Id"           = 99
                "Price"        = 0.99
                "Value"        = "Content"
            }
            
            $GetSample = '
            Post https://httpbin.org/post?id={Id}

            Content-Type: application/json
            Authorization: Bearer {QIBToken}
            
            {
                "id": {Id},
                "value": "{Value}"
            }'

            $Response = Invoke-PlainRequest -Syntax $GetSample -Context $Data
            $Response | Should Not BeNullOrEmpty
        }
    }
}

Get-Module -Name $ModuleName | Remove-Module