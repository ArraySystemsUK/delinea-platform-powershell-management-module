function Get-ITDRCollection {
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
        $body = @{
            filter     = @{
                createdBy         = @()
                effectiveAccessId = ""
                entityType        = @()
                ids               = @()
                isDeleted         = $false
                name              = $search
                status            = @()
                types             = @("User")
            }
            pagination = @{
                pageNumber     = 0
                recordsPerPage = $limit
                searchAfter    = @()
            }
            sort       = @{
                name      = "Name"
                direction = "Asc"
            }
        }
        $jsonBody = $body | ConvertTo-Json -Depth 5

        $apiResponse = Invoke-DelineaApi -method 'POST' -api 'inventory' -path '/collection/search' -body $jsonBody
        return $apiResponse
    }
    catch {
        throw "Failed to get collections from Delinea Inventory API: $_"
    }
}