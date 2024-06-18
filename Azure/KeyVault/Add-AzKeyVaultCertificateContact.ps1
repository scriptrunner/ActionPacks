#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Adds a contact for certificate notifications
    
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
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'VaultName' = $VaultName
                        'EmailAddress' = $MailAddress
                        'Confirm' = $false
                        'PassThru' = $null
    }
    $result = Add-AzKeyVaultCertificateContact @cmdArgs | Select-Object $Properties

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
