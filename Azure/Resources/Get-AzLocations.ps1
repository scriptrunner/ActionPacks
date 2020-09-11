#Requires -Version 5.0
#Requires -Modules Az.Resources

<#
    .SYNOPSIS
        Gets all locations and the supported resource providers for each location
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Resources
#>

param( 
)

Import-Module Az.Resources

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    $ret = Get-AzLocation @cmdArgs | Sort-Object DisplayName | Select-Object *

    if($SRXEnv) {
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