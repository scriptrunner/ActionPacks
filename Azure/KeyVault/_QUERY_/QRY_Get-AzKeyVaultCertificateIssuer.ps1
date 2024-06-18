#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets a certificate issuer for a key vault
    
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
                        'Name' = $CertificateName
    }
    $result = Get-AzKeyVaultCertificateIssuer @cmdArgs | Select-Object *

    foreach($itm in $result){
        if($null -ne $SRXEnv){
            $null = $SRXEnv.ResultList.Add($itm.Name)            
            $null = $SRXEnv.ResultList2.Add($itm.Name) # Display
        }
        else{
            Write-Output $itm.Name
        }
    }    
}
catch{
    throw
}
