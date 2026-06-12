function Get-DelineaUserSecrets { 
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory = $true)] 
        [ValidateNotNullOrEmpty()] 
        [int]$userId
    ) 

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try { 
        $body = @{ 
            Id                  = 5 
            Name                = "" 
            Parameters          = @( 
                @{ 
                    name  = "USER" 
                    value = $userId 
                    #valueDisplayName  = "Abbi Procter (Information Security)" 
                } 
            ) 
            EncodeHtml          = $false 
            DualControlApproval = @{ 
                Username  = $null 
                Password  = $null 
                DomainId  = $null 
                TwoFactor = "" 
            } 
            PageNumber          = 1 
            RecordsPerPage      = 500 
            IsAscending         = $true 
            previewSql          = $null 
            useDatabasePaging   = $false 
        } 
        $json = $body | ConvertTo-Json -Depth 5 
        $response = Invoke-RestMethod "$($script:apiBase.secretserver)/reports/execute" -Method POST -Headers $script:headers -body $json 
        return $response 
    } 
    catch { 
        Write-Error "API call failed: $_" 
    } 
}