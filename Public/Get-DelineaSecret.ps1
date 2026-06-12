function Get-DelineaSecret { 
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')] 
        [int]$SecretId, 

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')] 
        [string]$SecretName, 

        [Parameter(Mandatory = $false)] 
        [boolean]$full, 

        [Parameter(Mandatory = $false)] 
        [boolean]$summary = $true 
    ) 

    try {
        $null = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    # We will collect all IDs to process in this array
    $targetIds = @()

    if ($PSCmdlet.ParameterSetName -eq 'ById') {
        $targetIds += $SecretId
    }
    else {
        # Search for secret by name
        # Secret Server uses 'filter.searchText' for name-based searches
        try {
            $searchUrl = "$($script:apiBase.secretserver)/secrets?filter.searchText=$([Uri]::EscapeDataString($SecretName))"
            $searchResponse = Invoke-RestMethod -Uri $searchUrl -Method GET -Headers $script:headers
            
            if ($searchResponse.records.Count -eq 0) {
                Write-Warning "No secrets found matching name: $SecretName"
                return $null
            }

            # Collect IDs from the search results
            $targetIds = $searchResponse.records.id
        }
        catch {
            Write-Error "Search failed: $_"
            return $null
        }
    }

    # Process each ID found
    $results = foreach ($id in $targetIds) {
        try { 
            if ($full) { 
                Invoke-RestMethod "$($script:apiBase.secretserver2)/secrets/$id" -Method GET -Headers $script:headers 
            } 
            elseif ($summary) { 
                Invoke-RestMethod "$($script:apiBase.secretserver)/secrets/secret-detail/$id/general?isEditMode=false&loadReadOnlyFlags=true" -Method GET -Headers $script:headers 
            }
        } 
        catch { 
            Write-Error "Failed to retrieve details for Secret ID $id : $_" 
        } 
    }

    return $results
}