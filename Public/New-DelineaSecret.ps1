function New-DelineaSecret { 
    <# 
  .SYNOPSIS 
    Add new secret to a existing Delinea folder. 
  #> 
    param ( 
        [Parameter(Mandatory = $true)]  
        [string]$secretName,
        [Parameter(Mandatory = $true)] 
        [int]$folderId, 
        [Parameter(Mandatory = $true)]
        $template
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    $secretName = $secretName.TrimEnd() 
    $template = $template.TrimEnd() 

    # make below an input or corrolate with Get-DelineaSecretTemplates before public
    # $templates = @{ 
    #     'cloud-t1c' = @{ Id = 1001; Domain = 'ASUK.onmicrosoft.com'; SecretPolicy = 101 } 
    #     'cloud-t1'  = @{ Id = 1002; Domain = 'ASUK.onmicrosoft.com'; SecretPolicy = 102 } 
    #     'cloud-t2'  = @{ Id = 1003; Domain = 'ASUK.onmicrosoft.com'; SecretPolicy = 103 } 
    #     't1'        = @{ Id = 1004; Domain = 'live.ASUK.local'; SecretPolicy = 104 }
    #     't2'        = @{ Id = 1005; Domain = 'live.ASUK.local'; SecretPolicy = 105 }
    #     1001        = @{ Id = 1001; Domain = 'ASUK.onmicrosoft.com'; SecretPolicy = 101 } 
    #     1002        = @{ Id = 1002; Domain = 'ASUK.onmicrosoft.com'; SecretPolicy = 102 } 
    #     1003        = @{ Id = 1003; Domain = 'ASUK.onmicrosoft.com'; SecretPolicy = 103 } 
    #     1004        = @{ Id = 1004; Domain = 'live.ASUK.local'; SecretPolicy = 104 } 
    #     1005        = @{ Id = 1005; Domain = 'live.ASUK.local'; SecretPolicy = 105 } 
    # } 
    try { 
        $normalised = if ($template -as [int]) { $template -as [int] } else { $template.ToString().ToLower() } 
        if ($templates.ContainsKey($normalised)) { 
            $templateId = $templates[$normalised].Id 
            $domain = $templates[$normalised].Domain 
            $secretPolicy = $templates[$normalised].SecretPolicy 
        } 
        else { 
            $templateId = $null 
            $domain = $null 
            return write-error "Unknown template value: $template" 
        } 
    } 
    catch { 
        throw "Error whilst normalising input for template during secreting creation." 
    } 
   
    try { 
        $payload = [pscustomobject]@{   
            data = [pscustomobject]@{ 
                name               = $secretName
                folderId           = $folderId
                #enableInheritSecretPolicy = $true
                secretPolicy       = $secretPolicy
                site               = '1' #note: string type for number
                templateId         = $templateId
                fields             = @(
                    [pscustomobject]@{ slug = 'username'; value = $secretName }
                    [pscustomobject]@{ slug = 'password'; value = "2#!xD(qZ)5M(l^qKjndwocmWJo#6t%mkfqdG(Lp`$b!FJkwjkAJzzh" } # random password to satisfy pwd requirement on new secret. Password is actually set in RPC call next.
                    [pscustomobject]@{ slug = 'domain' ; value = $domain }
                )
                autoChangePassword = $true #true for user accounts
                generateSshKeys    = $false
            } 
        } 
        # Convert to JSON; increase -Depth for nested arrays/objects
        $body = $payload | ConvertTo-Json -Depth 6 -Compress
        #$body
        $newSecret = Invoke-WebRequest -uri "$($script:ApiBase.sysInternals)" -Method POST -headers $script:headers -body $body -ContentType "application/json" -UseBasicParsing
   
        #let Delinea catch up
        Start-Sleep -seconds 30 # can probably be scaled back but can't be bothered testing
    } 
    catch {
        throw "Error whilst creating Secret: $_"
    }
    try {
        if ($newSecret.content) {
            $resetPayload = [pscustomobject]@{
                data = [pscustomobject]@{
                    passwordType            = 0
                    nextPassword            = $null
                    sshType                 = 0
                    privateKeyPassphrase    = $null
                    privateKey              = $null
                    forceNextReset          = $false
                    doNotGeneratePassphrase = $false
                }
            }
            # Convert to JSON; increase -Depth for nested arrays/objects
            $resetBody = $resetPayload | ConvertTo-Json -Depth 6 -Compress
            $rpcNow = Invoke-WebRequest -uri "$($script:ApiBase.sysInternals)/$($newSecret.content)/change-password-now" -Method POST -headers $script:headers -body $resetBody -ContentType "application/json" -UseBasicParsing
     
            Start-Sleep -seconds 3
            return ($newSecret, $resetBody)
        }
        else {
            $newSecret
            throw $_
        }
    }
    catch {
        throw "Error whilst sending RPC: $_" 
    }
}