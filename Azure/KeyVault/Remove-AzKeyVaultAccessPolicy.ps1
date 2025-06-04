#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Removes all permissions for a user or application from a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults

    .Parameter EmailAddress
        [sr-en] Email address of the user whose access you want to remove
        [sr-de] E-Mail-Adresse des Benutzers, dessen Berechtigungen gelöscht werden sollen

    .Parameter UserPrincipalName
        [sr-en] UserPrincipalName of the user whose access you want to remove
        [sr-de] UserPrincipalName des Benutzers, dessen Berechtigungen gelöscht werden sollen
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ByEmailAddress')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ByUPN')]
    [string]$VaultName,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByEmailAddress')]
    [string]$EmailAddress,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByUPN')]
    [string]$UserPrincipalName
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Confirm' = $false
                'PassThru' = $null
    }
    if($PSCmdlet.ParameterSetName -eq 'ByUPN'){
        $cmdArgs.Add('UserPrincipalName',$UserPrincipalName)
    }
    else{
        $cmdArgs.Add('EmailAddress',$EmailAddress)
    }
    $ret = Remove-AzKeyVaultAccessPolicy @cmdArgs

    Write-Output $ret
}
catch{
    throw
}
finally{
}