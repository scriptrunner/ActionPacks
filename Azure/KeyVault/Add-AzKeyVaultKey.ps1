#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Creates a key in a key vault or imports a key into a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults
        
    .Parameter Destination
        [sr-en] Add the key as a software-protected key or an HSM-protected key 
        [sr-de] Schlüssel als softwaregeschützten Schlüssel oder als HSM-geschützten Schlüssel hinzufügen 

    .Parameter Name
        [sr-en] Name of the key to add to the key vault   
        [sr-de] Namen des Schlüssels
        
    .Parameter KeyType
        [sr-en] Key type of this key
        [sr-de] Schlüssel-Typ
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('HSM','Software')]
    [string]$Destination,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [ValidateSet('EC','RSA','oct')]
    [string]$KeyType
    )

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Name' = $Name
                        'Destination' = $Destination
                        'VaultName' = $VaultName
                        'Confirm' = $false
    }
    
    if($PSBoundParameters.ContainsKey('KeyType') -eq $true){
        $cmdArgs.Add('KeyType',$KeyType)
    }
    $ret = Add-AzKeyVaultKey @cmdArgs 

    Write-Output $ret
}
catch{
    throw
}
finally{
}