#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Imports a certificate to key vault
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault
        
    .Parameter CertificatePath
        [sr-en] Certificate name and path
        [sr-de] Name und Pfad des Zertifikats
        
    .Parameter Name
        [sr-en] Name of the key vault entry
        [sr-de] Name des Key-Vaults Eintrags
        
    .Parameter Vault
        [sr-en] Name of the key vault
        [sr-de] Name des Key-Vaults
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Vault,
    [Parameter(Mandatory = $true)]
    [string]$CertificatePath,    
    [Parameter(Mandatory = $true)]
    [string]$Name
)

Import-Module Az.KeyVault

try{
    $result = Import-AzKeyVaultCertificate -Name $Name -FilePath $CertificatePath -VaultName $Vault -ErrorAction Stop
    Write-Output $result
}
catch{
    throw
}
