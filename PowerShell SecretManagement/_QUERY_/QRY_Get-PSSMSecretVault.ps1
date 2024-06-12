#Requires -Version 5.0
#Requires -Modules Microsoft.PowerShell.SecretManagement

<#
    .SYNOPSIS
        Finds and returns registered vault informations
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/PowerShell Secretmanagement/_QUERY_
#>

param( 
)

Import-Module Microsoft.PowerShell.SecretManagement

try{ 
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    $vaults = Get-SecretVault @cmdArgs | Sort-Object Name

    foreach($itm in $vaults){
        if($null -ne $SRXEnv) {
            $null = $SRXEnv.ResultList.Add($itm.Name)
            $null = $SRXEnv.ResultList2.Add($itm.Name)
        }
        else{
            Write-Output $itm.Name
        }
    }
}
catch{
    throw
}
finally{
}