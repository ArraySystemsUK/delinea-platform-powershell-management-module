function Get-DelineaAllSecrets {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]$take = 100,
        [Parameter(Mandatory = $false)]
        [int]$skip = 0
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try {
        $apiResponse = Invoke-DelineaApi -method 'GET' -api 'ssv2' -path "/secrets?filter.doNotCalculateTotal=true&filter.extFieldsCombined=Datasource%2CInference%20Provider%2CMachine%2CNotes%2COrganization%2CProject%20text%2CUsername&filter.includeActive=true&filter.includeInactive=false&filter.includeRestricted=true&filter.permissionRequired=1&filter.scope=All&skip=$skip&sortBy%5B0%5D.direction=asc&sortBy%5B0%5D.name=name&take=$take"
        return $apiResponse
    }
    catch {
        throw "Failed to get all Delinea secrets view: $_"
    }
}