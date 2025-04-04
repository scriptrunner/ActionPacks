﻿#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Authentication 

<#
    .SYNOPSIS        
        Add-MgEnvironment
        
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

    .Parameter Name
        [sr-en] Name
        [sr-de]

    .Parameter AzureADEndpoint
        [sr-en] AzureADEndpoint
        [sr-de]

    .Parameter GraphEndpoint
        [sr-en] GraphEndpoint
        [sr-de]
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$AzureADEndpoint,
    [Parameter(Mandatory = $true)]
    [string]$GraphEndpoint
)

Import-Module Microsoft.Graph.Authentication 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'AzureADEndpoint' = $AzureADEndpoint
                'GraphEndpoint' = $GraphEndpoint
                'Name' = $Name
                'Confirm' = $false
    }
    $result = Add-MgEnvironment @cmdArgs | Select-Object *

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
}