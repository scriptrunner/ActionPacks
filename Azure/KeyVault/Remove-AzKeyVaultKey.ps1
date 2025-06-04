#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Deletes a key in a key vault
    
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
        
    .Parameter InRemovedState
        [sr-en] Remove the previously deleted key permanently
        [sr-de] Gelöschten Schlüssel endgültig entfernen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$KeyName,
    [switch]$InRemovedState
)

Import-Module Az.KeyVault

try{

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $KeyName
                'Confirm' = $false
                'PassThru' = $null
                'Force' = $null
    }
    
    if($InRemovedState.IsPresent -eq $true){
        $cmdArgs.Add('InRemovedState',$InRemovedState)
    }
    $ret = Remove-AzKeyVaultKey @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}