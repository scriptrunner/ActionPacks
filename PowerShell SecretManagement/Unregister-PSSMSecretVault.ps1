#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
    .SYNOPSIS
        Un-registers an extension vault from SecretManagement for the current user
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.PowerShell.SecretManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/PowerShell Secretmanagement
        
    .Parameter VaultName
        [sr-en] Name of the vault
        [sr-de] Vault-Name
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName
)

Import-Module Microsoft.PowerShell.SecretManagement

try{ 
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Name' = $VaultName
                    'Confirm' = $false
    }
    $null = Unregister-SecretVault @cmdArgs | Select-Object *
    $result = Get-SecretVault -ErrorAction Stop | Sort-Object Name

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
finally{
}