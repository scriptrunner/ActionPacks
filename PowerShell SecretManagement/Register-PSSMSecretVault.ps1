#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretManagement,Microsoft.PowerShell.SecretStore

<#
    .SYNOPSIS
        Registers a SecretManagement extension vault module for the current user
    
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
        [sr-en] Name of the new vault
        [sr-de] Vault-Name
        
    .Parameter Description
        [sr-en] Description
        [sr-de] Beschreibung
        
    .Parameter DefaultVault
        [sr-en] Set the new vault as default vault
        [sr-de] Vault als Standard-Vault konfigurieren
        
    .Parameter OverwriteExistingVault
        [sr-en] Overwrite an existing registered extension vault with the same name
        [sr-de] Überschreiben eines existierenden Vaults mit dem selben Namen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [string]$Description,
    [switch]$DefaultVault,
    [switch]$OverwriteExistingVault
)

Import-Module Microsoft.PowerShell.SecretManagement
Import-Module Microsoft.PowerShell.SecretStore

try{ 
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
            'ModuleName' = 'Microsoft.PowerShell.SecretStore'
            'Name' = $VaultName
            'AllowClobber' = $OverwriteExistingVault
            'DefaultVault' = $DefaultVault
            'Confirm' = $false
            'PassThru' = $null
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    $vault = Register-SecretVault @cmdArgs

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