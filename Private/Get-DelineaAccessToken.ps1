function Get-DelineaAccessToken { 
    <# 
  .SYNOPSIS 
    Retrieve the Secret Server Bearer token 
 #> 
    param ( 
        [boolean]$useTwoFactor,
        [boolean]$reauth = $false,
        [boolean]$refresh = $false,
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()] 
        [string]$delineaUri,
        [string]$username = "Local-Account-Example@Domain"
    ) 

    try {  
        $OAuthHeaders = $null 
        If ($UseTwoFactor) { 
            $OAuthHeaders = @{ 
                "OTP" = (Read-Host -Prompt "Enter your OTP for 2FA: ") 
            } 
        } 

        # Order of importance based on provided parameters: Reauth > Refresh > Cached token (if valid) > Prompt for credentials
        if ($reauth) {
            Write-Host "Reauthenticating, please enter credentials..." -ForegroundColor Yellow
            $script:Credentials = Get-Credential -Message "Please enter Delinea Platform API Account Credentials" -UserName $username
        }
        elseif ($script:Auth.TokenExpiration -lt (Get-Date) -and $script:Credentials -and !$reauth) {
            $refresh = $true
        }
        elseif (($script:Credentials -and $script:Auth.TokenExpiration -gt (Get-Date)) -and !$refresh) {
            Write-Host "Existing access token is still valid. Using cached token..." -ForegroundColor Green
            return $script:Auth
        }
        elseif (!$script:Credentials) {
            Write-Host "Please enter credentials..." -ForegroundColor Yellow
            $script:Credentials = Get-Credential -Message "Please enter Delinea Platform API Account Credentials" -UserName $username
        }

        if ($refresh) {
            # Refresh token
            $creds = @{
                client_id     = $script:Credentials.UserName
                client_secret = $script:Credentials.GetNetworkCredential().Password # don't know why this is needed for a refresh
                scope         = "xpmheadless"
                grant_type    = "client_credentials"
                refresh_token = $script:Auth.refresh_token
            }
        }
        else {
            # New auth
            $creds = @{
                client_id     = $script:Credentials.UserName
                client_secret = $script:Credentials.GetNetworkCredential().Password
                scope         = "xpmheadless"
                grant_type    = "client_credentials"
            }       
        }
        
        $response = Invoke-RestMethod "$delineaUri" -Method Post -Body $creds -Headers $OAuthHeaders -ContentType "application/x-www-form-urlencoded" 
        #$response = Invoke-RestMethod "$delineaUri/identity/api/oauth2/token/xpmplatform" -Method Post -Body $creds -Headers $OAuthHeaders -ContentType "application/x-www-form-urlencoded" 

        if ($response) {    
            $tokenExpiration = (Get-Date).AddSeconds($response.expires_in)
            $response | add-member -NotePropertyName tokenExpiration -NotePropertyValue $tokenExpiration -Force 
            return $response
        } 
        else { 
            throw "ERROR: Failed to authenticate. 
        $_" 
        }    
    } 

    catch [System.Net.WebException] {
        $script:Credentials = $null
        write-error $_.Exception 
        write-error $_.Exception.Response.StatusCode 
        write-error $_.Exception.Response.StatusDescription 
        $result = $_.Exception.Response.GetResponseStream() 
        $reader = New-Object System.IO.StreamReader($result) 
        $reader.BaseStream.Position = 0 
        $reader.DiscardBufferedData() 
        $responseBody = $reader.ReadToEnd() 
        throw $responseBody  
    } 
}