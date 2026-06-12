function Get-DelineaFolder { 
    <# 
  .SYNOPSIS 
    Check if folder exist given the parent folder  
#> 
    [CmdletBinding()] 
    param (  
        [Parameter(Mandatory = $true)] 
        [string]$folderName,
        [Parameter(Mandatory = $true)] 
        [int]$searchFolderId 
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try { 
        $folderSearchFilter = "?filter.searchText=$folderName&filter.parentFolderId=$searchFolderId" 
        $folderSearchResults = Invoke-RestMethod "$($script:apiBase.secretserver)/folders$folderSearchFilter" -Method GET -Headers $script:headers -ContentType "application/json" 
    } 
    catch { 
        throw $_ 
    } 
    if ($folderSearchResults.total -eq 0) { 
        ##No Folder is available   
        return 0 
    } 
    elseif ($folderSearchResults.total -eq 1) { 
        ## get folder id 
        $returnedFolder = $folderSearchResults.records[0] 
        return $returnedFolder.id 
        #idk what delinea is doing here 
        # if ($parentFolder.folderName -eq $folderInLoop) { 
        #   $returnedFolderId = $returnedFolder.id 
        #   return $returnedFolderId 
        # } 
        else { 
            return 0 
        } 
    } 
    elseif ($folderSearchResults.total -gt 1) { 
        ## get folder id 
        ##Again wtf is going on here, will this even work?? 
        $returnedFolderId = 0 
        foreach ($folderinsubloop in $folderSearchResults.records) { 
            if ($folderinsubloop.folderName -eq $foldername -and $folderinsubloop.parentFolderId -eq $searchFolderId) { 
                $returnedFolderId = $folderinsubloop.id 
            } 
        } 
        return $returnedFolderId 
    } 
    else { 
        ##More than 1 folder exists with the same name, cannot continue 
        throw "Cannot continue, more than one folder with same name exists." 
    } 
}