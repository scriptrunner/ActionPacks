#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Creates a secret in a key vault
    
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

    .Parameter SecretName
        [sr-en] Name of the secret
        [sr-de] Namen des Secrets
        
    .Parameter SecretValue
        [sr-en] Value of the secret
        [sr-de] Wert des Secrets

    .Parameter SecretName
        [sr-en] Disables the secret
        [sr-de] Secret deaktivieren
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$SecretName,
    [Parameter(Mandatory = $true,HelpMessage="ASRDisplay(Password)")]
    [string]$SecretValue,
    [bool]$Disable
)

Import-Module Az.KeyVault

try{
    [string[]]$Properties = @('VaultName','Name','NotBefore','Expires')
    $objSec = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $SecretName
                'SecretValue' = $objSec
                'Disable' = $Disable
                'Confirm' = $false
    }
    $ret = Set-AzKeyVaultSecret @cmdArgs | Select-Object $Properties

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