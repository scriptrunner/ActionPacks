#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Recovers a deleted certificate in a key vault into an active state
    
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
        [sr-de] Namen des Key Vaults
        
    .Parameter CertificateName
        [sr-en] Name of the certificate
        [sr-de] Name des Zertifikats
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$CertificateName
)

Import-Module Az.KeyVault

try{

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $CertificateName
                'Confirm' = $false
    }
    $ret = Undo-AzKeyVaultCertificateRemoval @cmdArgs | Select-Object *

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}