#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets the certificate policy from key vault
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az.KeyVault

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/KeyVault
        
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

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
