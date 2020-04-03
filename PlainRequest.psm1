
function Get-Matches() {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Content,
        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )
    Return [regex]::matches($Content, $Pattern, "Multiline")
}

function Get-Translation() {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Template,
        [Parameter(Mandatory = $true)]
        [PSObject]$Context
    )
    
    $Pattern = "{(.*?)}"
    $Matches1 = Get-Matches -Content $Template -Pattern $Pattern
    $Result = $Template

    $Matches1 | ForEach-Object {
        $Search = $_.Groups[0]
        $TargetKey = $_.Groups[1].ToString()
        $Target = $Context[$TargetKey]
        if ($null -ne $Target) {
            $Result = $Result -replace $Search, $Target
        }
    }

    return $Result
}

function Get-WebRequestDefinition() {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Template,
        [Parameter(Mandatory = $true)]
        [PSObject]$Context
    )
    $RequestObject = @{};
    $EndpointPattern = "^(\w+)\s+(.*?)$"
    $HeaderPattern = "^([a-zA-Z\-]+):\s+(.*?)$"
    $PayloadPattern = "^{([\s\S]*)}$"

    $BasicMatches = Get-Matches -Content $Template -Pattern $EndpointPattern
    if (!$BasicMatches.Success -or ($BasicMatches.Groups.Count -ne 3)) {
        return @{Success= $false}
    } 
    $RequestObject.Add("Method", $BasicMatches.Groups[1].Value)
    $Uri = Get-Translation -Template $BasicMatches.Groups[2].Value -Context $Context
    $RequestObject.Add("Uri", $Uri)

    $HeaderMatches = Get-Matches -Content $Template -Pattern $HeaderPattern
    if ($HeaderMatches.Success) {
        $Headers = @{};
        $HeaderMatches | ForEach-Object {
            $HeaderValue = Get-Translation -Template $_.Groups[2] -Context $Context
            $Headers.Add($_.Groups[1].Value, $HeaderValue)
        }
        $RequestObject.Add("Headers", $Headers)
    } 
    $PayloadMatches = Get-Matches -Content $Template -Pattern $PayloadPattern
    if ($PayloadMatches.Success) {
        $Raw = Get-Translation -Template $PayloadMatches.Value -Context $Context
        $Payload = $Raw | ConvertFrom-Json
        $RequestObject.Add("Body", $Payload)
    } 
    $RequestObject.Add("Success", $true);
    return $RequestObject
}


function Invoke-PlainRequest() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Template,
        [Parameter(Mandatory = $false)]
        [PSObject]$Context = @{}
    )

    $Request = Get-WebRequestDefinition -Template $Template -Context $Data    
    return Invoke-RestMethod -Method $Request.Method -Uri $Request.Uri -Headers $Request.Headers -Body $Request.Body -ContentType "application/json" -usebasicparsing
}

Export-ModuleMember -Function Invoke-PlainRequest
