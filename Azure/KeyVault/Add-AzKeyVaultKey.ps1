#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Creates a key in a key vault or imports a key into a key vault
    
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
        
    .Parameter Destination
        [sr-en] Add the key as a software-protected key or an HSM-protected key 
        [sr-de] Schlüssel als softwaregeschützten Schlüssel oder als HSM-geschützten Schlüssel hinzufügen 

    .Parameter Name
        [sr-en] Name of the key to add to the key vault   
        [sr-de] Namen des Schlüssels
        
    .Parameter KeyType
        [sr-en] Key type of this key
        [sr-de] Schlüssel-Typ
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('HSM','Software')]
    [string]$Destination,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [ValidateSet('EC','RSA','oct')]
    [string]$KeyType
    )

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Name' = $Name
                        'Destination' = $Destination
                        'VaultName' = $VaultName
                        'Confirm' = $false
    }
    
    if($PSBoundParameters.ContainsKey('KeyType') -eq $true){
        $cmdArgs.Add('KeyType',$KeyType)
    }
    $ret = Add-AzKeyVaultKey @cmdArgs 

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