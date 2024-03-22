#Requires -Version 5.0
#Requires -Modules Az.KeyVault

<#
    .SYNOPSIS
        Gets key vaults
    
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
#>

param( 
)

Import-Module Az.KeyVault

try{
    [string[]]$Properties = @('VaultName')
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}

    $result = Get-AzKeyVault @cmdArgs | Sort-Object VaultName | Select-Object $Properties
    foreach($itm in $result){
        if($null -ne $SRXEnv) {
            $null = $SRXEnv.ResultList.Add($itm.VaultName)            
            $null = $SRXEnv.ResultList2.Add($itm.VaultName) # Display
        }
        else{
            Write-Output $itm.VaultName
        }
    }
}
catch{
    throw
}
finally{
}