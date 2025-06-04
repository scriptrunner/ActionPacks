#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Deletes a secret in a key vault
    
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
        
    .Parameter InRemovedState
        [sr-en] Remove the previously deleted secret permanently
        [sr-de] Gelöschtes Secret endgültig entfernen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$SecretName,
    [switch]$InRemovedState
)

Import-Module Az.KeyVault

try{

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $SecretName
                'Confirm' = $false
                'PassThru' = $null
                'Force' = $null
    }
    
    if($InRemovedState.IsPresent -eq $true){
        $cmdArgs.Add('InRemovedState',$InRemovedState)
    }
    $ret = Remove-AzKeyVaultSecret @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}