#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets a certificate issuer for a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults
        
    .Parameter Issuer
        [sr-en] Email address of the contact to remove
        [sr-de] Mailadresse des Kontakts
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$Issuer
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $Issuer
                'Confirm' = $false
                'PassThru' = $null
                'Force' = $null
    }
    $ret = Remove-AzKeyVaultCertificateIssuer @cmdArgs

    Write-Output $ret
}
catch{
    throw
}
finally{
}