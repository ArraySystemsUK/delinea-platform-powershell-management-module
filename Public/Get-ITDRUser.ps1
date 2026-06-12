function Get-ITDRUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]$limit = 100,
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
        $apiResponse = Invoke-DelineaApi -method 'GET' -api 'ITDR' -path ('/accounts?skip=0&limit={0}&sort=account.name&order=asc&filter=%7B%22$and%22:%5B%7B%22identity.name%22:%7B%22$begins%22:%22{1}%22%7D%7D%5D%7D' -f $limit, $search)
        return $apiResponse
    }
    catch {
        throw "Failed to get user from Delinea ITDR API: $_"
    }
}