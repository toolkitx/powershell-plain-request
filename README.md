PlainRequest
=============
PlainRequest is inspired by the HTTP Client in WebStrom, allow you to

- Compose an HTTP request by using general syntax
- Use variables to parametrize elements
- Intergate with Pester


## Installation

Running this PowerShell command

```ps
Install-Module -Name PlainRequest	
```


## Syntax

```
Method Request-URI
Header-field: Header-value

Request-Body
```

Compose HTTP request as bellow:
```ps
Invoke-PlainRequest -Syntax $Syntax [-Context $ContextData]
```

### Get Request Syntax
```
GET https://httpbin.org/ip
Content-Type: application/json 
```

### POST Request Syntax
```
POST https://httpbin.org/post

Content-Type: application/json

{
    "id": 1,
    "value": "the-value"
}
```


## Use Variables

When composing an HTTP request, you can parametrize its elements by using variables. To provide the variable inside the request, enclose it in double curly braces as `{variable}`. 

```PS
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

$Sample = '
Post https://httpbin.org/post?id={Id}

Content-Type: application/json
Authorization: Bearer {QIBToken}

{
    "id": {Id},
    "value": "{Value}"
}'

$Response = Invoke-PlainRequest -Syntax $Sample -Context $Data
```


### TODO

- [ ] Support compose requests from single file
- [ ] Predefined dynamic variables
- [ ] Compose several requests in a single syntax, separate by `###`
- [ ] Break long requests into several lines
- [ ] Support multipart/form-data content type
- [ ] Export response to file