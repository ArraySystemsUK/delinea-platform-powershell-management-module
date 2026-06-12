function Connect-DelineaPlatform {  
    [CmdletBinding()]
    param ( 
        [string]$delineaUri,
        [boolean]$useTwoFactor = $false,
        [boolean]$reauth = $false,
        [boolean]$refresh = $false,
        [string]$username
    ) 

    # try {
    #     if ($script:Auth.TokenExpiration -gt (Get-Date)) {
    #         Write-Warning "Existing authentication session is active. Please disconnect before calling Connect-DelineaPlatform again."
    #     }
    # }
    # catch {
    #     throw "Checking authentication status failed: $_"
    # }

    If (!$delineaUri) { 
        $config = $Global:delineaConfig
        $script:urlBase = [PSCustomObject]@{ 
            platform     = $config.urlBase.Platform
            secretServer = $config.urlBase.SecretServer
        }
        $delineaUri = $config.OAuth.TokenEndpoint
        $script:delineaUri = $config.OAuth.TokenEndpoint
        $script:username = $config.OAuth.Username
        $script:ownerGroupId = $config.ManagementGroups.globalOwnerGroupId
        $script:apiGroupId = $config.ManagementGroups.apiGlobalOwnerGroupId
        $script:apiBase = [PSCustomObject]@{ 
            platform      = $config.ApiBase.Platform
            secretServer  = $config.ApiBase.SecretServer
            secretServer2 = $config.ApiBase.SecretServer2
            sysInternals  = $config.ApiBase.sysInternals
            itdr          = $config.ApiBase.itdr
            inventory     = $config.ApiBase.inventory
        }
    }
    else {
        $script:delineaUri = $delineaUri
    }

    if ($reauth) {
        write-host "Re-authenticating with Delinea Platform... you will be prompted to enter your credentials." -ForegroundColor Green
        $script:auth = Get-DelineaAccessToken -delineaUri $script:delineaUri -username $script:username -reauth $true
    }
    elseif ($refresh) {
        write-host "Refreshing auth token with Delinea Platform..." -ForegroundColor Green
        $script:auth = Get-DelineaAccessToken -delineaUri $script:delineaUri -username $script:username -refresh $true
    }
    else {
        $script:auth = Get-DelineaAccessToken -delineaUri $script:delineaUri -username $script:username
    }
    
    if (!$script:auth.access_token) { 
        throw "Auth token is empty" 
    } 
    $script:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]" 
    $script:headers.Add("Authorization", "Bearer $($script:auth.access_token)") 
    $script:headers.Add("Content-Type", "application/json") 
    $script:headers.add("accept", "application/json")   
    return [PSCustomObject]@{ 
        user             = $script:Credentials.UserName
        tokenExpiration  = $script:auth.tokenExpiration
        # auth             = $script:auth
        # headers          = $script:headers
        # token            = $script:auth.access_token
        platformUrl      = $script:urlBase.Platform
        secretServerUrl  = $script:urlBase.SecretServer
        platformApi      = $script:apiBase.Platform 
        secretServerApi  = $script:apiBase.SecretServer 
        secretServerApi2 = $script:apiBase.SecretServer2
        sysInternalsApi  = $script:apiBase.sysInternals
        itdrApi          = $script:apiBase.itdr
        inventoryApi     = $script:apiBase.inventory
    } 
}