function New-DelineaFolder { 
    <# 
    .SYNOPSIS 
    Create a new folder in Delinea, and add standard owners. 
  #> 
    param (
        [Parameter(Mandatory = $true)]
        [string]$folderName,
        [Parameter(Mandatory = $true)]
        [int]$parentFolderId,
        [Parameter(Mandatory = $false)]
        [boolean]$inheritPermissions = $true,
        [boolean]$inheritSecretPolicy = $true,
        [int]$secretPolicyId,
        [ValidateNotNullOrEmpty()]
        $ownerGroupId = $script:ownerGroupId, #Global admin owner group to prevent lockout and allow Delinea Admins to see all folders.
        [ValidateNotNullOrEmpty()]
        $apiGroupId = $script:apiGroupId #API owner group to prevent lockout and all API accounts to see all folders.
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }

    try {
        $folderStub = Invoke-RestMethod "$($script:ApiBase.secretserver)/folders/stub" -Method GET -Headers $script:headers -ContentType "application/json"
        if ($parentFolderId -eq -1) {
            $folderStub.inheritPermissions = $false
            $folderStub.inheritSecretPolicy = $false
            $folderStub.secretPolicyId = -1
        } 
        else { 
            $folderStub.inheritPermissions = $inheritPermissions 
            $folderStub.inheritSecretPolicy = $inheritSecretPolicy 
            if ($inheritSecretPolicy -eq $false) { 
                if (!$secretPolicyId) { throw 'Please provide a secret policy ID or set secret policy inheritance to True.' } 
                $folderStub.secretPolicyId = $SecretPolicyId 
            } 
        }             
        $folderStub.parentFolderId = $parentFolderId
        $folderStub.folderName = $folderName
        $folderStub.folderTypeId = 1
        $folderArgs = $folderStub | ConvertTo-Json
        $folderCreateResponse = Invoke-RestMethod "$($script:ApiBase.secretserver)/folders" -Method POST -Body $folderArgs -Headers $script:headers -ContentType "application/json"
        $createdFolder = $folderCreateResponse
    }
    catch {
        throw $_
    }
    if ($createdFolder -and !$inheritPermissions) {
        try {
            $addPermissionResponseGlobalOwnerGroup = Add-DelineaFolderPermission -groupId $ownerGroupId -folderId $createdFolder.id -folderPermission 'Owner' -secretPermission 'Owner' -quiet $true
            $addPermissionResponseApiServiceGroup = Add-DelineaFolderPermission -groupId $apiGroupId -folderId $createdFolder.id -folderPermission 'Owner' -secretPermission 'Owner' -quiet $true
        }
        catch {
            write-warning "Failed adding additional Owner permission to $($createdFolder.id)"
            write-error $_
        }
    }
    return $createdFolder
}