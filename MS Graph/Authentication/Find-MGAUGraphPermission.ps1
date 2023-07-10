#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Authentication 

<#
    .SYNOPSIS        
        Finds Microsoft Graph permissions based on search criteria
        
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
        Requires Modules Microsoft.Graph.Authentication 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Authentication

    .PARAMETER Online
        [sr-en] Online
        [sr-de]
        
    .PARAMETER PermissionType
        [sr-en] PermissionType
        [sr-de]
#>

param( 
    [switch]$Online,
    [ValidateSet('Any','Application','Delegated')]
    [string]$PermissionType
)

Import-Module Microsoft.Graph.Authentication 

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{
        ErrorAction = 'Stop'
        All = $null
    }
    if($Online.IsPresent -eq $true){
        $cmdArgs.Add('Online',$null)    
    }
    if($PSBoundParameters.ContainsKey('PermissionType') -eq $true){
        $cmdArgs.Add('PermissionType',$PermissionType)
    }
    $result = Find-MgGraphPermission @cmdArgs | Select-Object * | Sort-Object Name

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