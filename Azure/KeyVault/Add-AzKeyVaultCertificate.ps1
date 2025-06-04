#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Adds a certificate to a key vault
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.KeyVault

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults
        
    .Parameter Destination
        [sr-en] Add the key as a software-protected key or an HSM-protected key 
        [sr-de] Schlüssel als softwaregeschützten Schlüssel oder als HSM-geschützten Schlüssel hinzufügen 

    .Parameter Name
        [sr-en] Name of the certificate to add
        [sr-de] Namen des Zertifikats

    .PARAMETER CurveName
        [sr-en] Elliptic curve name of the key of the certificate
        [sr-de] Elliptic curve name des Zertifikatsschlüssels

    .PARAMETER IssuerName
        [sr-en] Name of the issuer for the certificate
        [sr-de] Name des Ausstellers des Zertifikats

    .PARAMETER SubjectName
        [sr-en] Subject name of the certificate for policy
        [sr-de] Name des Zertifikats der Policy

    .PARAMETER SecretContentType
        [sr-en] Name of the issuer for the certificate
        [sr-de] Name des Ausstellers des Zertifikats

    .PARAMETER KeyNotExportable
        [sr-en] Key is not exportable
        [sr-de] Schlüssel des Zertifikats kann nicht exportiert werden
        
    .Parameter KeySize
        [sr-en] Key size of the certificate
        [sr-de] Schlüsselgröße des Zertifikats

    .PARAMETER KeyType
        [sr-en] Key type of the key that backs the certificate
        [sr-de] Typ des Schlüssels

    .PARAMETER ValidityInMonths
        [sr-en] Number of months the certificate is valid
        [sr-de] Anzahl der Monate, in denen das Zertifikat gültig ist
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$IssuerName,
    [Parameter(Mandatory = $true)]
    [string]$SubjectName,
    [ValidateSet('application/x-pkcs12','application/x-pem-file')]
    [string]$SecretContentType = 'application/x-pkcs12',
    [ValidateSet('P-256','P-384','P-521','P-256K','SECP256K1')]
    [string]$CurveName,
    [switch]$KeyNotExportable,
    [ValidateSet('RSA','RSA-HSM','EC','EC-HSM')]
    [string]$KeyType,
    [ValidateSet('256','384','521','2048','3072','4096')]
    [string]$KeySize,
    [int]$ValidityInMonths = 6
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'IssuerName' = $IssuerName
                        'SubjectName' = $SubjectName
                        'SecretContentType' = $SecretContentType
                        'ValidityInMonths' = $ValidityInMonths
                        'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('CurveName') -eq $true){
        $cmdArgs.Add('Curve',$CurveName)
    }
    if($PSBoundParameters.ContainsKey('KeySize') -eq $true){
        $cmdArgs.Add('KeySize',$KeySize)
    }
    if($PSBoundParameters.ContainsKey('KeyType') -eq $true){
        $cmdArgs.Add('KeyType',$KeyType)
    }
    if($KeyNotExportable.IsPresent -eq $true){
        $cmdArgs.Add('KeyNotExportable',$null)
    }
    $cerPolicy = New-AzKeyVaultCertificatePolicy @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Name' = $Name
                'CertificatePolicy' = $cerPolicy
                'VaultName' = $VaultName
                'Confirm' = $false
    }
    $ret = Add-AzKeyVaultCertificate @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}