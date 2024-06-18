#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Backs up a key in a key vault
    
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

    .Parameter KeyName
        [sr-en] Name of the key bundle to get
        [sr-de] Namen des Key Bundles
        
    .Parameter BackupPath
        [sr-en] The output file to store the backup of the key
        [sr-de] Name und Pfad der Exportdatei
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [Parameter(Mandatory = $true)]
    [string]$KeyName,
    [Parameter(Mandatory = $true)]
    [string]$BackupPath
)

Import-Module Az.KeyVault

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
                'Name' = $KeyName
                'OutputFile' = $BackupPath
                'Confirm' = $false
                'Force' = $null
    }
    $ret = Backup-AzKeyVaultKey @cmdArgs | Select-Object *

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