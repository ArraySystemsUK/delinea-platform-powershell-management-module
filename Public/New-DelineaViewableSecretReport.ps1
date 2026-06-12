function New-DelineaViewableSecretsReport { 
    [CmdletBinding()] 
    [OutputType([PSCustomObject])] 
    param( 
        [Parameter(Mandatory = $false)] 
        $SuccessCsvExportLocation = "C:\temp\DelineaSecretReport04-03-2026 v3.csv", 
        $NoSecretsCsvExportLocation = "C:\temp\DelineaSecretReport04-03-2026 NoSecrets.csv", 
        $take = 5000
    ) 

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    #Viewable Secrets Check 
    $successfulUsers = New-Object System.Collections.Generic.List[PSCustomObject] 
    $noSecretsUsers = New-Object System.Collections.Generic.List[PSCustomObject] 
    #Get all Delinea Users 
    try { 
        $usersToCheck = Get-DelineaUser -searchterm "" -take $take
    } 
    catch { 
        throw $_ 
    } 
    foreach ($user in $usersToCheck.records) { 
        $secrets = Get-DelineaUserSecrets -userId $user.id 
        if ($secrets.rows.count -lt 1) { 
            $noSecretsUsers.add([PSCustomObject]@{ 
                    UserPrincipalName = $user.userName 
                    Secrets           = "N/A" 
                    DelineaUserID     = $user.id 
                    Enabled           = $user.enabled 
                }) 
        } 
        if ($secrets.rows.count -lt 500) { 
            $columns = $secrets.columns 
            $rows = $secrets.rows 
            # Create a list to store converted row objects 
            foreach ($row in $rows) { 
                # Split the row on whitespace 
                $values = $row -split '\s{2,}' # split on 2+ spaces 
                # Create ordered hashtable matching column names to row values 
                $obj = [ordered]@{ 
                    Name = $user.userName 
                } 
                for ($i = 0; $i -lt $columns.Count; $i++) { 
                    $obj[$columns[$i]] = $values[$i] 
                } 
                $successfulUsers.add([pscustomobject]$obj) 
            } 
        } 
    } 
    # Export to CSV 
    $successfulUsers | Export-Csv -Path "C:\temp\DelineaSecretReport04-03-2026 v3.csv" -NoTypeInformation -append -Encoding UTF8 
    $noSecretsUsers | Export-Csv -Path "C:\temp\DelineaSecretReport04-03-2026 NoSecrets.csv" -NoTypeInformation -append -Encoding UTF8 
}