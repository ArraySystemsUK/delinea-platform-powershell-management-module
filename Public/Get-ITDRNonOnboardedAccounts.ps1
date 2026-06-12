function Get-ITDRNonOnboardedAccounts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$collectionId, # Accepts either a single string or an array of strings

        [Parameter(Mandatory = $false)]
        [Alias("limit")]
        [int]$take = 10000
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try {
        # 1. Initialize a list to hold all objects from all provided collections
        $allCollectionAccounts = [System.Collections.Generic.List[psobject]]::new()

        foreach ($id in $collectionId) {
            # Get collection data for this specific ID
            $results = Get-ITDRCollectionResults -collectionId $id -limit $take
    
            # Add the entire account objects to the master list
            if ($null -ne $results.data) {
                $allCollectionAccounts.AddRange([psobject[]]$results.data)
            }
        }

        # 2. Get existing secrets for comparison
        $secrets = Get-DelineaAllSecrets -take $take

        # 3. Create a clean reference list of Secret Server account names
        # Wrap in @() to guarantee it's an array, replace the suffix, and explicitly trim whitespace.
        $onboardedSecretNames = @($secrets.records.name) | ForEach-Object { 
            ($_ -replace '@.*', '').Trim() 
        }

        # 4. Find the missing Accounts (Outputs the whole object)
        $notOnboardedAccounts = @($allCollectionAccounts) | Where-Object {
            $rawUPN = $_.properties.userprincipalname
            
            # Catch null/empty UPNs immediately
            if ([string]::IsNullOrWhiteSpace($rawUPN)) {
                # Returning $true flags this object as "not onboarded" so you can review it,
                # Some have no UPN so can't be matched to a Secret Server account.
                # Need to double check where these null values are coming from.
                return $true 
            }

            # Strip the domain and trim whitespace from the current UPN
            $cleanUPN = ($rawUPN -replace '@.*', '').Trim()
            
            # Compare the clean UPN against the already-cleaned list of secrets
            $cleanUPN -notin $onboardedSecretNames
        }
        if ($notOnboardedAccounts.count -gt 0) {
            return $notOnboardedAccounts
        }
        else {
            return "All accounts within the provided collections are already onboarded to Delinea."
        }
    }
    catch {
        throw "Failed to get collection results from Delinea ITDR API: $_"
    }
}