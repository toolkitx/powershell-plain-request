Import-Module -Name .\PlainRequest.psm1

$Sample = "{TokenUrl}, {ClientSecret}, {ClientId}, {AuthResource} - {NotExistItem}"
$Data = @{
    "TokenUrl"     = 111
    "ClientSecret" = "222"
    "ClientId"     = "333"
    "AuthResource" = "444"
    "Username" = "User1"
    "Password" = "Password"
    "Id" = 99
    "Price" = 0.99
    "Value" = "Content"
}

$GetSample = @"
Get https://httpbin.org/ip

Content-Type: application/json
Authorization: Basic {Username} {Password}
"@

$Response = Invoke-PlainRequest -Template $GetSample -Context $Data
Write-Host $Response


$PostSample = @"
Post https://httpbin.org/post?id={Id}

Content-Type: application/json
Authorization: Bearer {QIBToken}

{
    "id": {Id},
    "value": "{Value}"
}
"@

$PostResponse = Invoke-PlainRequest -Template $PostSample -Context $Data
Write-Host $PostResponse
$Result = $PostSample | Invoke-PlainRequest
Write-Host $Result
