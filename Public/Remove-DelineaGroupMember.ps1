function Remove-DelineaPlatformGroupMember { 
    param( 
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()] 
        $userId, 
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()]
        $groupId
    ) 

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try { 
        # Create the body as a PowerShell object 
        $body = @{ 
            Name   = $groupId 
            Users  = @{ 
                Delete = @( 
                    $userId 
                ) 
            } 
            Roles  = @{ 
                Delete = @() 
            } 
            Groups = @{} 
        } 
        # Convert to JSON 
        $bodyArgs = $body | ConvertTo-Json -Depth 5 
        $apiResponse = Invoke-RestMethod "$($script:ApiBase.platform)/LocalGroups/UpdateLocalGroup" -Method POST -Headers $script:headers -body $bodyArgs -ContentType "application/json" 
        return $apiResponse 
    } 
    catch { 
        Write-Error "API call failed: $_" 
    } 
}