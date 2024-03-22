#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Removes all permissions for a user or application from a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az.KeyVault

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/KeyVault

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

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}