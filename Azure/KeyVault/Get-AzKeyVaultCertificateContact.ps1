#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets contacts that are registered for certificate notifications for a key vault
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault
        
    .Parameter VaultName
        [sr-en] Name of the key vault
        [sr-de] Name des Key-Vaults
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName
)

Import-Module Az.KeyVault

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'VaultName' = $VaultName
    }
    $result = Get-AzKeyVaultCertificateContact @cmdArgs | Select-Object *

    Write-Output $result
}
catch{
    throw
}
