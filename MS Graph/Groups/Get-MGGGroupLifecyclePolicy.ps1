#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        Get entity from groupLifecyclePolicies by key
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Groups 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Groups
      
    .Parameter GroupLifecyclePolicyId
        [sr-en] Id of groupLifecyclePolicy
        [sr-de] ID der groupLifecyclePolicy
#>

param( 
    [string]$GroupLifecyclePolicyId
)

Import-Module Microsoft.Graph.Groups

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if($PSBoundParameters.ContainsKey('GroupLifecyclePolicyId') -eq $true){
        $cmdArgs.Add('GroupLifecyclePolicyId',$GroupLifecyclePolicyId)
    }
    else {
        $cmdArgs.Add('All',$null)
    }
    $result = Get-MgGroupLifecyclePolicy @cmdArgs | Select-Object *

    if($SRXEnv) {
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
    DisconnectMSGraph
}