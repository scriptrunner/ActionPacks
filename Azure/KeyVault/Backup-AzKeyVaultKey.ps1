#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Backs up a key in a key vault
    
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
        
    .Parameter BackupPath
        [sr-en] The output file to store the backup of the key
        [sr-de] Name und Pfad der Exportdatei
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$KeyName,
    [Parameter(Mandatory = $true)]
    [string]$BackupPath
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $KeyName
                'OutputFile' = $BackupPath
                'Confirm' = $false
                'Force' = $null
    }
    $ret = Backup-AzKeyVaultKey @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}