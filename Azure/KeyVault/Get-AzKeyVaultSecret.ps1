#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets the secrets in a key vault
    
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
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [string]$SecretName,
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
    
    if([System.String]::IsNullOrWhiteSpace($SecretName) -eq $false){
        $cmdArgs.Add('Name',$SecretName)
    }

    $ret = Get-AzKeyVaultSecret @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}