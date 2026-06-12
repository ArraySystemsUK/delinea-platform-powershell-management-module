function Get-DelineaCheckedOutSecrets {
    [CmdletBinding()]
    param(
        # The maximum number of secrets to query at once (handles pagination)
        [int]$MaxRecords = 5000
    )

    try {
        # Ensure we are authenticated
        $null = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    # Query the secrets summary endpoint. We use 'take' to pull a large batch to avoid pagination loops for most environments.
    $url = "$($script:apiBase.secretserver)/secrets?take=$MaxRecords"

    try {
        Write-Verbose "Fetching secret summaries to check for active lockouts..."
        $response = Invoke-RestMethod -Method Get -Uri $url -Headers $script:headers

        # Filter the results where the secret is currently checked out
        $checkedOutSecrets = $response.records | Where-Object { $_.isCheckedOut -eq $true }

        if (-not $checkedOutSecrets) {
            Write-Host "No secrets are currently checked out." -ForegroundColor Green
            return
        }

        # Format the output what is open and who has it
        $results = foreach ($secret in $checkedOutSecrets) {
            [PSCustomObject]@{
                SecretId     = $secret.id
                SecretName   = $secret.name
                FolderId     = $secret.folderId
                CheckedOutBy = $secret.checkOutUserDisplayName
                # checkOutUserId = $secret.checkOutUserId # Uncomment user ID for logic
            }
        }

        return $results
    }
    catch {
        Write-Error "Failed to retrieve checked-out secrets. Error: $_"
    }
}