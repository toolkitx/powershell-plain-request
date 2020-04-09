
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
    
    $Pattern = "{{(.*?)}}"
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
    $EndpointPattern = "^\s*?(GET|POST|PUT|DELETE|PATCH)\s+(.*?)$"
    $HeaderPattern = "^\s*?([a-zA-Z\-]+):\s*(.*?)$"
    $PayloadPattern = "^\s*?{([\s\S]*)}$"

    $BasicMatches = Get-Matches -Content $Template -Pattern $EndpointPattern
    if (!$BasicMatches.Success -or ($BasicMatches.Groups.Count -ne 3)) {
        return @{Success= $false}
    } 
    $Method = Get-RequestMethod -InputMethod $BasicMatches.Groups[1].Value
    $RequestObject.Add("Method", $Method)
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
        #$Payload = $Raw | ConvertFrom-Json
        $RequestObject.Add("Body", $Raw)
    } 
    $RequestObject.Add("Success", $true);
    return $RequestObject
}

function Get-RequestMethod() {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$InputMethod
    )
    $Method = $InputMethod.substring(0,1).toUpper() + $InputMethod.substring(1).toLower()  
    return $Method
}


function Invoke-SimpleRequest() {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Syntax,
        [Parameter(Mandatory = $false)]
        [PSObject]$Context = @{}
    )
    $Spliter = '#{3,}'
    $RequestSyntaxes = [regex]::Split($Syntax, $Spliter)
    if ($RequestSyntaxes.Length -eq 0) {
        return null
    }
    else {
        $RequestSyntaxes | ForEach-Object  {
            $Request = Get-WebRequestDefinition -Template $_ -Context $Context    
            Invoke-WebRequest -Method $Request.Method -Uri $Request.Uri -Headers $Request.Headers -Body $Request.Body -ContentType "application/json"
        }
    }
}

Export-ModuleMember -Function Invoke-SimpleRequest
