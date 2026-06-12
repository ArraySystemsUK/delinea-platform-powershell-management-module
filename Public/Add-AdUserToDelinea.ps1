function Add-AdUserToDelinea { 
    [CmdletBinding()]
    param ( 
        [Parameter(Mandatory = $true)] 
        [string]$upn, 
        [Parameter(Mandatory = $true)] 
        [string]$adGuid, 
        [Parameter(Mandatory = $false)] 
        [string]$displayName
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try { 
        $body = [PSCustomObject]@{ 
            type         = "User" 
            platformUuid = $adGuid 
            entityName   = $upn 
            #displayName = $displayName 
        } 
        $body2 = [PSCustomObject]@{ 
            data = @($body) 
        } 
        $bodyArgs = $body2 | ConvertTo-Json 
        $apiResponse = Invoke-RestMethod "$($script:ApiBase.SecretServer)/platform/create-users-and-groups" -Method POST -Headers $script:headers -body $bodyArgs -ContentType "application/json" 
        if ($apiResponse.error) { 
            throw $apiResponse.error 
        } 
        else { 
            return $apiResponse.data 
        } 
    } 
    catch { 
        throw "Failed to onboard to Delinea: $_"  
    } 
}