# Delinea Platform and Secret Server PowerShell Management Module
A PowerShell module that aims to simplify API calls to Delinea Platform and Secret Server by packaging REST API calls into easily useable Powershell cmdlets.

<ins>**Please be aware that this is a heavily unfinished product and should only be used as a template.**</ins>

## JSON Breakdown:
Currently, the module will only work properly if you update Config\ModuleConfig.json with your instances details.
| JSON Reference | Description |
| --- | --- |
| Tenant: | This is not used anywhere in the module currently |
| UrlBase:Platform | The URL of your Delinea Platform instance |
| UrlBase:SecretServer | The URL of your Secret Server instance |
| OAuth:TokenEndpoint | The URL used to log into Delinea via the API |
| OAuth:Username | The username of the API account you'd like to use (this is pre-populated in a pop-up credential window when called) |
| ApiBase:Platform | Used by the script to call the Delinea Platform API Endpoint |
| ApiBase:SecretServer | Used by the script to call the Delinea Sercret Server V1 API Endpoint |
| ApiBase:SecretServer2 | Used by the script to call the Delinea Sercret Server V2 API Endpoint |
| ApiBase:sysInternals | Used by the script to call the Delinea Sercret Server Secret Internals Endpoint |
| ApiBase:itdr | Used by the script to call the Delinea Platform ITDR API Endpoint |
| ApiBase:inventory | Used by the script to call the Delinea Platform Discovery/Inventory API Endpoint |
| ManagementGroups:globalOwnerGroupId | The groupID of the group that contains your Delinea admins. This ID is used when creating new folders and is added as "Owners" by default. This allows admins to see all created folders. |
| ManagementGroups:apiGlobalOwnerGroupId | The groupID of the group that contains your API admins. This ID is used when creating new folders and is added as "Owners" by default. This allows API accounts to see all created folders. |
| Logging:Level | Doesn't do anything |

## Available Cmdlets
| Cmdlet | Description | Mandatory Parameters
| --- | --- | --- |
| Add-AdUserToDelinea | Adds a Active Directory user to the Delinea Directory (Platform Connector) | -UPN -ADGUID |
| Add-AllowedTemplatesToDelineafolder | Adds allowed templates to a given folder ID | -AllowedTemplateID -FolderID |
| Add-DelineaFolderPermission | Add Group or user permission to a given folder ID | -FolderID -FolderPermission -SecretPermission -GroupID/-UserID |
| Connect-DelineaPlatform | Description |  |
| Disconnect-DelineaPlatform | Description |  |
| Edit-DelineaSecret | Description |  |
| Get-DelineaAllSecrets | Description |  |
| Get-DelineaCheckedOutSecrets | Description |  |
| Get-DelineaFolder| Description |  |
| Get-DelineaPlatformUser | Description |  |
| Get-DelineaSecret | Description |  |
| Get-DelineaSecretTemplates | Description |  |
| Get-DelineaUser | Description |  |
| Get-DelineaUserSecrets | Description |  |
| Get-InactiveDelineaUsers | Description |  |
| Get-ITDRCollection | Description |  |
| Get-ITDRCollectionResults | Description |  |
| Get-ITDRNonOnboardedAccounts | Description |  |
| Get-ITDRUser | Description |  |
| Invoke-DelineaApi | Description |  |
| New-DelineaFolder | Description |  |
| New-DelineaSecret | Disabled until template rework for public use. |  |
| New-DelineaViewableSecretsReport | Description |  |
| Remove-DelineaPlatformGroupMember | Description |  |
| Remove-DelineaPlatformUser | Description |  |
