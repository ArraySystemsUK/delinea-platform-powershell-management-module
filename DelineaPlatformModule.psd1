@{
    RootModule           = 'DelineaPlatformModule.psm1'
    ModuleVersion        = '0.0.1'
    GUID                 = '11111111-2222-3333-4444-555555555555'
    Author               = 'Array Systems'
    Description          = 'PowerShell Module for Delinea Platform & Secret Server APIs'
    PowerShellVersion    = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core') 
    FunctionsToExport    = @(
        'Add-AdUserToDelinea',
        'Add-AllowedTemplatesToDelineaFolder',
        'Add-DelineaFolderPermission',
        'Connect-DelineaPlatform',
        'Disconnect-DelineaPlatform',
        'Edit-DelineaSecret',
        'Get-DelineaAllSecrets',
        'Get-DelineaCheckedOutSecrets',
        'Get-DelineaFolder',
        'Get-DelineaPlatformUser',
        'Get-DelineaSecret', # TODO - add checkout logic to public
        'Get-DelineaSecretTemplates',
        'Get-DelineaUser',
        'Get-DelineaUserSecrets',
        'Get-InactiveDelineaUsers',
        'Get-ITDRCollection',
        'Get-ITDRCollectionResults',
        'Get-ITDRNonOnboardedAccounts',
        'Get-ITDRUser',
        'Invoke-DelineaApi',
        'New-DelineaFolder',
        # 'New-DelineaSecret', TODO - make public
        # 'New-StandardDelineaUserOnboard', TODO - make public
        # 'New-DelineaViewableSecretsReport', - TODO - sort function output + make public
        'Remove-DelineaPlatformGroupMember',
        'Remove-DelineaPlatformUser'
        # 'Remove-InactiveDelineaUsers', TODO - make public
        # 'Set-DelineaSecretCheckin' TODO - make public
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()
}