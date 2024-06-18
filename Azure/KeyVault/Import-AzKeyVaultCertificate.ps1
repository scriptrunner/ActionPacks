#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Imports a certificate to key vault
    
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
