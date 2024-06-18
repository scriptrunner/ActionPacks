#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets the key rotation policy for the specified key in Key Vault
    
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