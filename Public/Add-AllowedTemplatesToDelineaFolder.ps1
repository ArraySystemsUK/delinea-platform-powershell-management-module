function Add-AllowedTemplatesToDelineaFolder { 
    <# 
  .SYNOPSIS 
    Add Template restrictions to a folder 
  #> 
    [CmdletBinding()]
    param ( 
        [Parameter(Mandatory)] 
        $AllowedTemplateID, 
        $folderId
    )

    try {
        $auth = Get-DelineaPlatformAuth
    }
    catch {
        throw "Authentication failed: $_"
    }
    
    try { 
        $addtemplatetofolderbody = "{`"data`":{`"allowedTemplates`":[$AllowedTemplateID]}}"  
        $addtemplatetofolderresponse = $null 
        $addtemplatetofolderresponse = Invoke-WebRequest -Uri "$($script:apiBase.secretserver)/folder/$folderId" -Method "PATCH" -Headers $script:headers -Body $addtemplatetofolderbody -UseBasicParsing 
    } 
    catch { 
        throw $_ 
    } 
    return $addtemplatetofolderresponse 
} 