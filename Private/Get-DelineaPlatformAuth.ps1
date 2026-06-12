function Get-DelineaPlatformAuth { 
    [CmdletBinding()]
    param (
        [string]$delineaUri
    )
    try {
        if (!$script:Auth -or !$script:Credentials) {
            write-host "No existing auth context found. Attempting to connect to Delinea Platform using default config..." -ForegroundColor Yellow
            $script:connect = Connect-DelineaPlatform
            return $script:connect
        }
        elseif ($script:Auth.TokenExpiration -gt (Get-Date)) {
            write-host "Existing access token is still valid. Using cached token..." -ForegroundColor Green
            return "ExistingAuthSession"
        }
        elseif ($script:Auth.TokenExpiration -lt (Get-Date)) {
            write-host "Access token expired. Refreshing..." -ForegroundColor Yellow
            $script:connect = Connect-DelineaPlatform -refresh $true
            return $script:connect
        }
        else {
            write-host "Unexpected auth state. Reauthenticating..." -ForegroundColor Yellow
            $script:connect = Connect-DelineaPlatform -reauth $true
            return $script:connect
        }
    }
    catch { 
        throw "Failed to retrieve auth context: $_"
    }
}