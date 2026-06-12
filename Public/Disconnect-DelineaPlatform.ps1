function Disconnect-DelineaPlatform {
    [CmdletBinding()]
    param (
    )

    if (!($script:Auth.TokenExpiration -gt (Get-Date))) {
        $script:Auth = $null
        $script:Credentials = $null
        throw "No valid sign-in session."
    }

    try {
        $apiResponse = Invoke-DelineaApi -method 'POST' -api 'Platform' -path "security/logout?allowIWA=false"
        $script:Auth = $null
        $script:Credentials = $null
        return $apiResponse
    }
    catch {
        throw "Failed to disconnect from Delinea Platform: $_"
    }
}