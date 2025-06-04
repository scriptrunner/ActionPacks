#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Creates a secret in a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults

    .Parameter SecretName
        [sr-en] Name of the secret
        [sr-de] Namen des Secrets
        
    .Parameter SecretValue
        [sr-en] Value of the secret
        [sr-de] Wert des Secrets

    .Parameter Disable
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

    Write-Output $ret
}
catch{
    throw
}
finally{
}