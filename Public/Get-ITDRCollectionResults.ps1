function Get-ITDRCollectionResults {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]$limit = 10000,
        [Parameter(Mandatory = $true)]
        [string]$collectionId
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try {
        $apiResponse = Invoke-DelineaApi -method 'GET' -api 'ITDR' -path ('/accounts?skip=0&limit={0}&sort=account.name&order=asc&filter=%7B%22$and%22:%5B%7B%22account.dynamicScopes%22:%7B%22$in%22:%5B%22{1}%22%5D%7D%7D%5D%7D' -f $limit, $collectionId)
        return $apiResponse
    }
    catch {
        throw "Failed to get collection results from Delinea ITDR API: $_"
    }
}