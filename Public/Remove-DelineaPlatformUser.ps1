function Remove-DelineaPlatformUser { 
    param( 
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()] 
        $userId
    ) 

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    $inputType = $userId.GetType().Name 
    try { 
        if ($inputType -eq "Array") { 
            $body = @{ 
                Users = $userId 
            } 
        } 
        elseIf ($inputType -eq "String") { 
            $body = @{ 
                Users = @( 
                    $userId 
                ) 
            } 
        } 
        else { 
            throw "UserId must be an Array or String type." 
        } 
        $bodyArgs = $body | ConvertTo-Json -Depth 5 
        $apiResponse = Invoke-RestMethod "$($script:ApiBase.platform)/UserMgmt/RemoveUsers" -Method POST -Headers $script:headers -body $bodyArgs -ContentType "application/json" 
        return $apiResponse 
    } 
    catch { 
        Write-Error "API call failed: $_" 
    } 
}