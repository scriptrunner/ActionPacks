#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Authentication 

<#
    .SYNOPSIS        
        Set-MgRequestContext
        
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

    .PARAMETER ClientTimeout
        [sr-en] ClientTimeout
        [sr-de]

    .PARAMETER MaxRetry
        [sr-en] MaxRetry
        [sr-de]

    .PARAMETER RetryDelay
        [sr-en] RetryDelay
        [sr-de]

    .PARAMETER RetriesTimeLimit
        [sr-en] RetriesTimeLimit
        [sr-de]
#>

param( 
    [int]$ClientTimeout,
    [int]$MaxRetry,
    [int]$RetryDelay,
    [int]$RetriesTimeLimit
)

Import-Module Microsoft.Graph.Authentication 

try{ 
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('ClientTimeout') -eq $true){
        $cmdArgs.Add('ClientTimeout',$ClientTimeout)
    }
    if($PSBoundParameters.ContainsKey('MaxRetry') -eq $true){
        $cmdArgs.Add('MaxRetry',$MaxRetry)
    }
    if($PSBoundParameters.ContainsKey('RetriesTimeLimit') -eq $true){
        $cmdArgs.Add('RetriesTimeLimit',$RetriesTimeLimit)
    }
    if($PSBoundParameters.ContainsKey('RetryDelay') -eq $true){
        $cmdArgs.Add('RetryDelay',$RetryDelay)
    }
    $result = Set-MgRequestContext @cmdArgs | Select-Object *

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