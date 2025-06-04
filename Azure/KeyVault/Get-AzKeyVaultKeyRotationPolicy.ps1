#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets the key rotation policy for the specified key in Key Vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults

    .Parameter KeyName
        [sr-en] Name of the key bundle to get
        [sr-de] Namen des Key Bundles
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$KeyName,
    [ValidateSet('*','VaultName','KeyName','Id','ExpiresIn','CreatedOn','UpdatedOn','LifetimeActions')]
    [string[]]$Properties = @('VaultName','KeyName','Id','ExpiresIn','CreatedOn','UpdatedOn')
)

Import-Module Az.KeyVault

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $KeyName
    }
    $ret = Get-AzKeyVaultKeyRotationPolicy @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}