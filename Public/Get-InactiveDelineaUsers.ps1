# Helper function to handle Delinea's JSON dates and null values safely
function Convert-DelineaDate {
    param([string]$JsonDateString)
    
    # If the user has never logged in, the string might be empty.
    # We return a very old date (MinValue) so they still get flagged as inactive.
    if ([string]::IsNullOrWhiteSpace($JsonDateString)) {
        return [DateTime]::MinValue
    }

    # Extract the milliseconds and convert to local time
    $milliseconds = [long]($JsonDateString -replace '\D')
    return [datetimeOffset]::FromUnixTimeMilliseconds($milliseconds).LocalDateTime
}

function Get-InactiveDelineaUsers {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        $thresholdDays = 90, #optional: number of days inactive - default: 90 days
        $domainFilter = $null,
        $take = 10000 #used in SS user call
    )

    ## Check for Delinea authentication context
    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }
    ##

    if (!$domainFilter.StartsWith('*')) {
        $domainFilter = "*$domainFilter"
    }

    ## Get all Delinea SS Users
    try {
        $ssUsersToCheck = Get-DelineaUser -searchterm "" -take $take
    }
    catch {
        throw "Failed to get Secret Server users to check: $_"
    }
    ##Inactivity Check on SS Users
    try {
        $cutoff = (Get-Date).AddDays(-$thresholdDays)
        $ssFiltered = $ssUsersToCheck.records | Where-Object {
            [DateTime]::Parse($_.lastlogin) -lt $cutoff -and [DateTime]::Parse($_.created) -lt $cutoff -and $_.userName -notlike "connector-*"
        }
        if ($domainFilter) {
            $ssFiltered = $ssFiltered | Where-Object { $_.userName -like $domainFilter }
        }
    }
    catch {
        throw "Error whilst filtering Secret Server users $_"
    }
    ##

    ##Get all Delinea Platform Users
    try {
        $platUsersToCheck = Get-DelineaPlatformUser -all $true
    }
    catch {
        throw "Failed to get Platform users: $_"
    }
    ##Inactivity Check on SS Users
    try {
        #Inactivity Check on Plat Users
        $cutoff = (Get-Date).AddDays(-$thresholdDays)

        $platFiltered = $platUsersToCheck | Where-Object {
            # Convert the raw JSON dates into real DateTime objects
            $lastLoginDate = Convert-DelineaDate -JsonDateString $_.lastlogin
            $createdDate = Convert-DelineaDate -JsonDateString $_.created

            $lastLoginDate -lt $cutoff -and $createdDate -lt $cutoff -and $_.status -ne "Suspended" -and $_.userName -notlike "connector-*"
        }
        if ($domainFilter) {
            $platFiltered = $platFiltered | Where-Object { $_.userName -like $domainFilter }
        }
    }
    catch {
        throw "Error whilst filtering Platform users $_"
    }
    ##

    ###################################################

    # Create a hash table and store the Secret Server user object
    $ssLookup = @{}
    foreach ($ssUser in $ssFiltered) {
        # map username to the whole $ssUser object
        $ssLookup[$ssUser.userName] = $ssUser
    }

    # Filter Platform users AND attach multiple new properties
    $inactiveUsers = $platFiltered | Where-Object { 
        $ssLookup.ContainsKey($_.userName) 
    } | Select-Object *, 
    @{Name = "ssLastLogin"; Expression = { $ssLookup[$_.userName].lastLogin } },
    @{Name = "ssCreatedDate"; Expression = { $ssLookup[$_.userName].created } },
    @{Name = "ssLoginFailures"; Expression = { $ssLookup[$_.userName].loginFailures } },
    @{Name = "ssId"; Expression = { $ssLookup[$_.userName].id } }

    if ($inactiveUsers.Count -gt 0) { 
        return [PSCustomObject]@{ 
            result             = "Inactive users found" 
            inactiveUsersCount = $inactiveUsers.Count 
            records            = $inactiveUsers
        } 
    } 
    else { 
        return [PSCustomObject]@{ 
            result             = "No inactive users"
            inactiveUsersCount = 0
            records            = $null
        } 
    } 
}