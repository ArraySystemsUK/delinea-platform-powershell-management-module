# delinea-platform-powershell-management-module
A PowerShell module that aims to simplify API calls to Delinea Platform and Secret Server by packaging REST API calls into easily useable Powershell cmdlets.

**Please be aware that this is a heavily unfinished product and should only be used as a template.**

Currently, the module will only work properly if you update Config\ModuleConfig.json with your instances details.

Example:

{
  "Tenant": "ASUK", // This is not used anywhere in module currently.

  "UrlBase": {
    "Platform": "https:///ASUK.delinea.app", // The URL of your Delinea Platform instance
    "SecretServer": "https://ASUK.secretservercloud.co.uk" // The URL of your Secret Server instance
  },

  "OAuth": {
    "TokenEndpoint": "https://ASUK.delinea.app/identity/api/oauth2/token/xpmplatform", // The URL used to log into Delinea via the API
    "Username": "D0-Api-Folder-Manager@ASUK" // The username of the API account you'd like to use (this is pre-populated in a pop-up credential window when called)
  },

  "ApiBase": {
    "Platform": "https://ASUK.delinea.app/identity/api", // Delinea Platform API Endpoint
    "SecretServer": "https://ASUK.secretservercloud.co.uk/api/v1", // Delinea Sercret Server V1 API Endpoint
    "SecretServer2": "https://ASUK.secretservercloud.co.uk/api/v2", // Delinea Sercret Server V2 API Endpoint
    "sysInternals": "https://ASUK.secretservercloud.co.uk/internals/secret-detail", // Delinea Sercret Server Secret Internals Endpoint
    "itdr": "https://ASUK.delinea.app/itdr/api", // Delinea Platform ITDR API Endpoint
    "inventory": "https://ASUK.delinea.app/inventory/api" // Delinea Platform Discovery/Inventory API Endpoint
  },

  "ManagementGroups": {
    "globalOwnerGroupId": 100, // The groupID of the group that contains your Delinea admins. This ID is used when creating new folders and is added as "Owners" by default. This allows admins to see all created folders.
    "apiGlobalOwnerGroupId": 101 // The groupID of the group that contains your API admins. This ID is used when creating new folders and is added as "Owners" by default. This allows API accounts to see all created folders.
  },

  "Logging": {
    "Level": "Info" // Doesn't do anything
  }
}
