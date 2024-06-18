#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
    .SYNOPSIS
        Finds and returns registered vault information
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.PowerShell.SecretManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/PowerShell Secretmanagement
        
    .Parameter VaultName
        [sr-en] Name of the vault
        [sr-de] Vault-Name
#>

param( 
    [string]$VaultName
)

Import-Module Microsoft.PowerShell.SecretManagement

try{ 
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    if($PSBoundParameters.ContainsKey('VaultName') -eq $true){
        $cmdArgs.Add('Name',$VaultName)
    }
    $vault = Get-SecretVault @cmdArgs | Select-Object *

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $vault
    }
    else{
        Write-Output $vault
    }
}
catch{
    throw
}
finally{
}