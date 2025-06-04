#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Backs up a secret in a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults

    .Parameter SecretName
        [sr-en] Name of the secret to back up
        [sr-de] Namen des Secrets
        
    .Parameter BackupPath
        [sr-en] The output file to store the backup of the secret
        [sr-de] Name und Pfad der Exportdatei
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$SecretName,
    [Parameter(Mandatory = $true)]
    [string]$BackupPath
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $SecretName
                'OutputFile' = $BackupPath
                'Confirm' = $false
                'Force' = $null
    }
    $ret = Backup-AzKeyVaultSecret @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}