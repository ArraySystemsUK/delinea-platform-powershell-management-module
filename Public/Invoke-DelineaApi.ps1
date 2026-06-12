function Invoke-DelineaApi {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory)][string]$Path,
        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')][string]$Method = 'GET',
        [object]$Body,
        [ValidateSet('platform', 'ssV1', 'ssV2', 'sysInternals', 'itdr', 'inventory', 'custom')][string]$Api = 'custom'
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    switch ($api) {
        'platform' { $baseUrl = $script:ApiBase.Platform }
        'ssV1' { $baseUrl = $script:ApiBase.SecretServer }
        'ssV2' { $baseUrl = $script:ApiBase.SecretServer2 }
        'sysInternals' { $baseUrl = $script:ApiBase.sysInternals }
        'itdr' { $baseUrl = $script:ApiBase.itdr }
        'inventory' { $baseUrl = $script:ApiBase.inventory }
        'custom' { $baseUrl = $null }
        default { throw "Invalid API specified: $Api" }
    }

    try {
        if ($api -ne 'custom' -and !$Path.StartsWith('/')) {
            $Path = "/$path"
        }
        "$baseUrl$Path"
        $apiResponse = Invoke-RestMethod "$baseUrl$Path" -Method $method -Headers $script:headers -body $body -ContentType "application/json"
        if ($apiResponse.error) {
            throw $apiResponse.error
        } 
        else {
            return $apiResponse
        }
    } 
    catch { 
        throw "Invoke-DelineaAPI call failed: $_"  
    }
}