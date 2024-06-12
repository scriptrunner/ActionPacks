#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretManagement,Microsoft.PowerShell.SecretStore

<#
    .SYNOPSIS
        Unlocks an extension vault so that it can be access in the current session
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.PowerShell.SecretManagement,Microsoft.PowerShell.SecretStore

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/PowerShell Secretmanagement
        
    .Parameter VaultName
        [sr-en] Name of the vault
        [sr-de] Vault-Name
        
    .Parameter StorePassword
        [sr-en] Password needed to access the store
        [sr-de] Kennwort für den Store Zugriff
        
    .Parameter VaultPassword
        [sr-en] Password needed to access the vault
        [sr-de] Kennwort für den Vault Zugriff
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [securestring]$StorePassword,
    [securestring]$VaultPassword
)

Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

try{ 
    if($null -ne $StorePassword){
        $null = Unlock-SecretStore -Password $StorePassword
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Name' = $VaultName
                    'Password' = $VaultPassword
    }
    $result = Unlock-SecretVault @cmdArgs

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}