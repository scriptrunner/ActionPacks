#Requires -Version 5.0
#Requires -Modules Az.Resources

<#
    .SYNOPSIS
        Gets all locations
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az.Resources

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/_QUERY_
#>

param( 
)

Import-Module Az.Resources

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    $ret = Get-AzLocation @cmdArgs | Sort-Object DisplayName | Select-Object *

    foreach($itm in $ret){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($itm.Location)
            
            $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # Display
        }
        else{
            Write-Output $itm.DisplayName
        }
    }
}
catch{
    throw
}
finally{
}