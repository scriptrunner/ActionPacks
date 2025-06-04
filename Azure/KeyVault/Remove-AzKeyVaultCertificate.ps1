#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Removes a certificate from a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults
        
    .Parameter CertificateName
        [sr-en] Name of the certificate
        [sr-de] Name des Zertifikats
        
    .Parameter InRemovedState
        [sr-en] Remove the previously deleted certificate permanently
        [sr-de] Gelöschtes Zertifikat endgültig entfernen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$CertificateName,
    [switch]$InRemovedState
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $CertificateName
                'Confirm' = $false
                'PassThru' = $null
                'Force' = $null
    }
    
    if($InRemovedState.IsPresent -eq $true){
        $cmdArgs.Add('InRemovedState',$InRemovedState)
    }
    $ret = Remove-AzKeyVaultCertificate  @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}