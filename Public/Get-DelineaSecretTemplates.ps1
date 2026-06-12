function Get-DelineaSecretTemplates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]$take = 500,
        [Parameter(Mandatory = $false)]
        [string]$search
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try {
        $apiResponse = Invoke-DelineaApi -method 'GET' -api 'ssV1' -path "secret-templates?filter.includeInactive=false&filter.includeSecretCount=true&skip=0&sortBy%5B0%5D.direction=Asc&sortBy%5B0%5D.name=name&take=$take"
        return $apiResponse
    }
    catch {
        throw "Failed to get Secret Templates from Delinea Secret Server API: $_"
    }
}