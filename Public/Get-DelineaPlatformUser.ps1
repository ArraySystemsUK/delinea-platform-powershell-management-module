#DELINEA API PROBLEM PREVENTING THIS FROM WORKING
# function Get-DelineaPlatformUser { 
#     [CmdletBinding()] 
#     [OutputType([array])] # Changed to array since we expect multiple results
#     param( 
#         [Parameter(Mandatory = $true)] 
#         [ValidateNotNullOrEmpty()] 
#         [string]$SearchTerm
#     ) 

#     try {
#         $auth = Get-DelineaPlatformAuth
#     }
#     catch {
#         throw "Authentication failed: $_"
#     }

#     try { 
#         # Safely encode the search term in case it contains spaces or special characters
#         $encodedSearch = [uri]::EscapeDataString($SearchTerm)
        
#         # Hit the base users endpoint using a query parameter for searching
#         $uri = "$($script:ApiBase.platform)/entities/users?filter=$encodedSearch"
        
#         # $response = 
#         Invoke-RestMethod -Uri $uri -Method GET -Headers $script:headers 
        
#         # if ($null -ne $response.items) {
#         #     return $response.items
#         # } elseif ($null -ne $response.value) {
#         #     return $response.value
#         # } else {
#         # return $response
#         # }
#     } 
#     catch { 
#         Write-Error "API call failed: $_" 
#     } 
# }

function Get-DelineaPlatformUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'direct')] 
        [string]$username, 
        [Parameter(Mandatory = $true, ParameterSetName = 'search')] 
        [ValidateNotNullOrEmpty()]
        [string]$SearchTerm,
        [Parameter(Mandatory = $true, ParameterSetName = 'all')] 
        [boolean]$all = $false
    ) 

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try {
        # Safely encode the search term in case it contains spaces or special characters - Not needed
        # $encodedSearch = [uri]::EscapeDataString($SearchTerm)

        if ($PSCmdlet.ParameterSetName -eq 'direct') {
            try { 
                $response = Invoke-RestMethod "$($script:ApiBase.platform)/entities/users/$userName" -Method GET -Headers $script:headers 
                return $response 
            } 
            catch { 
                Write-Error "API call failed: $_" 
            } 
        }
        else {
            if ($PSCmdlet.ParameterSetName -eq 'all') {
                $id = "user_all"
                $jsonSearchTerm = $null
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'search') {
                $id = "user_searchbyname"
                $jsonSearchTerm = "%" + $searchTerm + "%"
            }

            $body = @{
                ID   = $id
                Args = @{
                    PageNumber  = 1
                    PageSize    = 5000
                    Limit       = 5000
                    FilterQuery = $null
                    Caching     = 0
                    Ascending   = $true
                    SortBy      = "Username"
                    Parameters  = @(
                        @{
                            Name       = "searchString"
                            Value      = $jsonSearchTerm
                            Label      = "searchString"
                            Type       = "string"
                            ColumnType = 12
                        },
                        @{
                            Name       = "orderby"
                            Value      = "Username"
                            Label      = "orderby"
                            Type       = "string"
                            ColumnType = 12
                        }
                    )
                }
            }
            $json = $body | ConvertTo-Json -Depth 5
        
            $response = invoke-delineaapi -method "post" -api 'platform' -path '/report/runreport' -body $json  

            $toOutput = New-Object System.Collections.Generic.List[PSCustomObject]
            if ($response.success -eq $true) {
                if ($response.result.results.count -gt 0) {
                    foreach ($result in $response.result.results) {
                        $toOutput.add($result.row)
                    }
                }
            }

            if ($toOutput) {
                return $toOutput
            }
            else {
                write-host "No results found for $jsonSearchTerm"
            }
        }
    } 
    catch { 
        Write-Error "API call failed: $_" 
    }
}