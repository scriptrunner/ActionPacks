#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretManagement,Microsoft.PowerShell.SecretStore

<#
    .SYNOPSIS
        Runs an extension vault self test
    
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
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [securestring]$StorePassword
)

Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

try{ 
    if($null -ne $StorePassword){
        Unlock-SecretStore -Password $StorePassword
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Name' = $VaultName
    }
    $result = Test-SecretVault @cmdArgs | Select-Object *

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