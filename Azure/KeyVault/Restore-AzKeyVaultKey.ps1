#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Creates a key in a key vault from a backed-up key
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults
        
    .Parameter InputFile
        [sr-en] Input file that contains the backup of the key to restore
        [sr-de] Name und Pfad der Exportdatei zum Wiederherstellen des Schlüssels
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$InputFile
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'InputFile' = $InputFile
                'Confirm' = $false
    }
    $ret = Restore-AzKeyVaultKey @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}