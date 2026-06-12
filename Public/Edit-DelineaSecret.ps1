function Edit-DelineaSecret { 
    [CmdletBinding()] 
    param( 
        [Parameter(Mandatory = $true)]
        [hashtable]$Updates,
        [Parameter(Mandatory = $true)]
        $secretId
    )
    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try {
        $body = @{ data = @{} }
        $secretFields = @()

        foreach ($entry in $Updates.GetEnumerator()) {
            $slug = $entry.Key
            $value = $entry.Value

            if ($slug -in @('name', 'secretName')) {
                $body.data.name = @{
                    dirty = $true
                    value = $value
                }
            }
            else {
                $secretFields += @{
                    slug  = $slug
                    dirty = $true
                    value = $value
                }
            }
        }

        if ($secretFields) {
            $body.data.secretfields = $secretFields
        }

        $json = $body | ConvertTo-Json -Depth 4
        $json
    }
    catch {
        throw "Error constructing request body: $_"
    }

    try {
        $response = Invoke-RestMethod "$($script:apiBase.secretserver)/secrets/$secretId/general" -Method PATCH -headers $script:headers -body $json
        return $response 
    } 
    catch { 
        Write-Error "Get-DelineaUser API call failed: $_" 
    } 
}