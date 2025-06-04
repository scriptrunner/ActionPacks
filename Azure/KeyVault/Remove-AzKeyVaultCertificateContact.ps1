#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Deletes a contact that is registered for certificate notifications from a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults
        
    .Parameter EmailAddress
        [sr-en] Email address of the contact to remove
        [sr-de] Mailadresse des Kontakts
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$EmailAddress
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'EmailAddress' = $EmailAddress
                'Confirm' = $false
                'PassThru' = $null
    }
    $ret = Remove-AzKeyVaultCertificateContact @cmdArgs

    Write-Output $ret
}
catch{
    throw
}
finally{
}