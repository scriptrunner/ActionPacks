#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets the certificates from key vault
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault
        
    .Parameter VaultName
        [sr-en] Name of the key vault
        [sr-de] Name des Key-Vaults
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [ValidateSet('*','VaultName','Name','ContentType','NotBefore','Expires','Id','Version','Created','Updated','Enabled','Tags','TagsTable')]
    [string[]]$Properties = @('VaultName','Name','NotBefore','Expires')
)
 
Import-Module Az.KeyVault

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'VaultName' = $VaultName
    }
    $result = Get-AzKeyVaultCertificate @cmdArgs | Select-Object $Properties

    Write-Output $result
}
catch{
    throw
}
