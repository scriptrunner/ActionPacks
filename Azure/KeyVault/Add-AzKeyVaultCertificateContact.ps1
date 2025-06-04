#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Adds a contact for certificate notifications
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault
        
    .Parameter VaultName
        [sr-en] Name of the key vault
        [sr-de] Name des Key-Vaults
        
    .Parameter MailAddress
        [sr-en] Email address of the contact
        [sr-de] Mailadresse des Kontakts
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$MailAddress
)
 
Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'VaultName' = $VaultName
                        'EmailAddress' = $MailAddress
                        'Confirm' = $false
                        'PassThru' = $null
    }
    $result = Add-AzKeyVaultCertificateContact @cmdArgs | Select-Object *

    Write-Output $result
}
catch{
    throw
}
