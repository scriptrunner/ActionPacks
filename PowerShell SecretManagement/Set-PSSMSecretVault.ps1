#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
    .SYNOPSIS
        Sets the provided vault name as the default vault for the current user
    
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
        
    .Parameter ClearDefault
        [sr-en] Set default for all registered vaults to false
        [sr-de] Alle registierten Vaults auf 
#>

param( 
    [Parameter(Mandatory = $true, ParameterSetName = 'SetDefault')]
    [string]$VaultName,
    [Parameter(ParameterSetName = 'ClearDefault')]
    [bool]$ClearDefault = $true
)

Import-Module Microsoft.PowerShell.SecretManagement

try{ 
    $result = $null
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Confirm' = $false
    }
    if($PSCmdlet.ParameterSetName -eq 'SetDefault'){
        $cmdArgs.Add('Name',$VaultName)
        $null = Set-SecretVaultDefault @cmdArgs | Select-Object *
        $result = Get-SecretVault @cmdArgs | Select-Object *
    }
    else{
        $cmdArgs.Add('ClearDefault',$ClearDefault)
        $result = Get-SecretVault -ErrorAction Stop | Sort-Object Name
    }

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