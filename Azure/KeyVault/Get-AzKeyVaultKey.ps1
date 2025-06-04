#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets Key Vault keys
    
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
    [string]$KeyName,
    [ValidateSet('*','VaultName','Name','KeyType','CurveName','RecoveryLevel','IsHsm','Keysize','Enabled','Expires','NotBefore','Id','Version','Created','Updated','Tags','TagsTable')]
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
    
    if($PSBoundParameters.ContainsKey('KeyName') -eq $true){
        $cmdArgs.Add('Name',$KeyName)
    }
    $ret = Get-AzKeyVaultKey @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}