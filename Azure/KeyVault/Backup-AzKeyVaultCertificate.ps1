#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Backs up a certificate in a key vault
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault
        
    .Parameter VaultName
        [sr-en] Name of the key vault
        [sr-de] Name des Key-Vaults
        
    .Parameter CertificateName
        [sr-en] Name of the certificate
        [sr-de] Name des Zertifikats
        
    .Parameter BackupPath
        [sr-en] The output file to store the backup of the certificate
        [sr-de] Name und Pfad der Exportdatei
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$CertificateName,
    [Parameter(Mandatory = $true)]
    [string]$BackupPath
)
 
Import-Module Az.KeyVault

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'VaultName' = $VaultName
                        'Name' = $CertificateName
                        'OutputFile' = $BackupPath
                        Confirm = $false
                        Force = $null
    }
    $result = Backup-AzKeyVaultCertificate @cmdArgs

    Write-Output $result
}
catch{
    throw
}
