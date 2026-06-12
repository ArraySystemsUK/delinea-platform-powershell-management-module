function Get-DelineaUser { 
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory = $true)] 
        $SearchTerm, 
        [Parameter(Mandatory = $false)] 
        $take = 50
    )
    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }
    
    try {
        $response = Invoke-RestMethod "$($script:apiBase.secretserver)/users?filter.searchText=$SearchTerm&take=$take" `
            -Method GET `
            -Headers $script:headers
        return $response 
    } 
    catch { 
        Write-Error "Get-DelineaUser API call failed: $_" 
    } 
}