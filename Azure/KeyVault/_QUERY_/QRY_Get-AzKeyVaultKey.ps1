#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets Key Vault keys
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/KeyVault/_QUERY_

    .Parameter VaultName
        [sr-en] Name of the key vault   
        [sr-de] Namen des Key Vaults

    .PARAMETER IncludeRemoved
        [sr-en] Show removed key vault keys too
        [sr-de] Gelöschte KeyVault Schlüssel anzeigen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$VaultName,
    [bool]$IncludeRemoved
)

Import-Module Az.KeyVault

try{
    [string[]]$Properties = @('VaultName','Name','NotBefore','Expires')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'VaultName' = $VaultName
    }
    $ret = Get-AzKeyVaultKey @cmdArgs | Select-Object $Properties | Sort-Object Name

    foreach($itm in $ret){
        if($null -ne $SRXEnv) {
            $null = $SRXEnv.ResultList.Add($itm.Name)            
            $null = $SRXEnv.ResultList2.Add($itm.Name) # Display
        }
        else{
            Write-Output $itm.Name
        }
    }
    if($IncludeRemoved -eq $true){
        $ret = Get-AzKeyVaultKey @cmdArgs -InRemovedState | Select-Object $Properties | Sort-Object Name

        foreach($itm in $ret){
            if($null -ne $SRXEnv) {
                $null = $SRXEnv.ResultList.Add($itm.Name)            
                $null = $SRXEnv.ResultList2.Add("$($itm.Name) (removed)") # Display
            }
            else{
                Write-Output "$($itm.Name) (removed)"
            }
        }
    }
}
catch{
    throw
}
finally{
}