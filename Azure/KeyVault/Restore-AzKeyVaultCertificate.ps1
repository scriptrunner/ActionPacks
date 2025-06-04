#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Restores a certificate in a key vault from a backup file
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults
        
    .Parameter InputFile
        [sr-en] Input file that contains the backup of the certificate to restore
        [sr-de] Name und Pfad der Exportdatei zum Wiederherstellen des Zertifikats
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
    $ret = Restore-AzKeyVaultCertificate @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}