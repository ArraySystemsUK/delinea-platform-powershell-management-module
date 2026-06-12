function Add-DelineaFolderPermission { 
    <# 
  .SYNOPSIS 
    Add Group or user permission to a given Folder 
  #> 
    [CmdletBinding()]
    param ( 
        [Parameter(Mandatory)] 
        [int]$folderId, 
        [string]$folderPermission = "View", 
        [string]$secretPermission = "View", 
        [Parameter(Mandatory = $false)]
        [int]$groupId, 
        [int]$userId, 
        [boolean]$quiet = $false 
    ) 
    if ($groupId -and $userId) { 
        throw "Must provide EITHER groupID or userID, NOT BOTH. Erroring." 
    } 
    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }
    try { 
        write-host "Adding permissions for $($groupId+$userId) to $folderId" 
        $folderPermissionCreateArgs = Invoke-RestMethod "$($script:apiBase.secretserver)/folder-permissions/stub?filter.folderId=$folderId" -Method GET -Headers $script:headers -ContentType "application/json" 
        $folderPermissionCreateArgs.GroupId = $groupId 
        $folderPermissionCreateArgs.UserId = $userId 
        #To give permissions to a group, populate the GroupId variable and leave UserId $null. 
        #To give permissions to a user, populate the UserId variable and leave GroupId $null. 
        switch ($groupId + $userId) {
            { $groupId -eq 0 } { $folderPermissionCreateArgs.GroupId = $null } 
            { $userId -eq 0 } { $folderPermissionCreateArgs.UserId = $null } 
        }
        $folderPermissionCreateArgs.FolderAccessRoleName = $folderPermission 
        $folderPermissionCreateArgs.SecretAccessRoleName = $secretPermission 
        $permissionArgs = $folderPermissionCreateArgs | ConvertTo-Json
        $permissionResults = Invoke-RestMethod "$($script:apiBase.secretserver)/folder-permissions" -Method POST -Headers $script:headers -Body $permissionArgs -ContentType "application/json" 
    } 
    catch { 
        throw $_ 
    } 
    if (!$quiet) { 
        return $permissionResults 
    } 
}