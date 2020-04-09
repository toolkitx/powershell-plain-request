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
    } 
    
    Context "Request" {
        It "Should send GET request" {
            
            $syntax = "
            GET https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            Content-Type: application/json
            "

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -eq 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -eq "AuthToken"
            $Headers."x-custom-header" | Should -eq "CustomHeader"
        }

        It "Should support url variable" {
            
            $syntax = "
            GET https://httpbin.org/anything?id=1
            "

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -eq 200
            $args = ($Response.Content | ConvertFrom-Json).args
            $args.id | Should -eq "1"
        }

        It "Should send DELETE request" {
            
            $syntax = "
            DELETE https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader
            "

            $Response = Invoke-SimpleRequest -Syntax $syntax
            $Response.StatusCode | Should -eq 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -eq "AuthToken"
            $Headers."x-custom-header" | Should -eq "CustomHeader"
        }

        It "Should send POST request" {
            $data = @{
                "Id"           = 99
                "Value"        = "Content"
            }
            $syntax = '
            POST https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -eq 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -eq "AuthToken"
            $Headers."x-custom-header" | Should -eq "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -eq $data.Id
            $Content.json.value | Should -eq $data.Value
        }


        It "Should send PATCH request" {
            
            $data = @{
                "Id"           = 99
                "Value"        = "Content"
            }
            $syntax = '
            PATCH https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -eq 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -eq "AuthToken"
            $Headers."x-custom-header" | Should -eq "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -eq $data.Id
            $Content.json.value | Should -eq $data.Value
        }

        It "Should send PUT request" {
            
            $data = @{
                "Id"           = 99
                "Value"        = "Content"
            }
            $syntax = '
            PUT https://httpbin.org/anything

            Authorization: AuthToken
            x-custom-header: CustomHeader

            {
                "id": {{Id}},
                "value": "{{Value}}"
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $data
            $Response.StatusCode | Should -eq 200
            $Headers = ($Response.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -eq "AuthToken"
            $Headers."x-custom-header" | Should -eq "CustomHeader"
            $Content = $Response.Content | ConvertFrom-Json
            $Content.json.id | Should -eq $data.Id
            $Content.json.value | Should -eq $data.Value
        }

        It "Should compose several requests in a single syntax" {
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
            
            $syntax = '
            GET https://httpbin.org/get

            x-custom-header: CustomHeader
            Authorization: AuthToken

            ###

            POST https://httpbin.org/post

            Content-Type: application/json

            {
                "id": 1
            }
            '

            $Response = Invoke-SimpleRequest -Syntax $syntax -Context $Data
            $Response.Count | Should -eq 2

            $Response1 = $Response[0]
            $Response1.StatusCode | Should -eq 200
            $Headers = ($Response1.Content | ConvertFrom-Json).headers
            $Headers.Authorization | Should -eq "AuthToken"
            $Headers."x-custom-header" | Should -eq "CustomHeader"


            $Response2 = $Response[1]
            $Response2.StatusCode | Should -eq 200
            $Content = $Response2.Content | ConvertFrom-Json
            $Content.json.id | Should -eq 1
        }
    }
}

Get-Module -Name $ModuleName | Remove-Module