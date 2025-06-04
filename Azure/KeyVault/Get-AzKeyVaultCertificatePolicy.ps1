#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets the certificate policy from key vault
    
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
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$CertificateName,
    [ValidateSet('*','SubjectName','IssuerName','SecretContentType','Kty','KeySize','Curve','Exportable','Created','Updated','Enabled',
                'ReuseKeyOnRenewal','DnsNames','Emails','UserPrincipalNames','KeyUsage','Ekus','ValidityInMonths',
                'CertificateType','RenewAtNumberOfDaysBeforeExpiry','RenewAtPercentageLifetime','EmailAtNumberOfDaysBeforeExpiry','EmailAtPercentageLifetime','CertificateTransparency')]
    [string[]]$Properties = @('SubjectName','IssuerName','Kty','Enabled','Created','Updated')
)

Import-Module Az.KeyVault

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'VaultName' = $VaultName
                        'Name' = $CertificateName
    }
    $result = Get-AzKeyVaultCertificatePolicy @cmdArgs | Select-Object $Properties

    Write-Output $result
}
catch{
    throw
}
