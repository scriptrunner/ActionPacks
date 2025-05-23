﻿#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.SignIns

<#
    .SYNOPSIS
        Delete a users's temporaryAccessPassAuthenticationMethod object
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Identity.SignIns

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter MethodId
        [sr-en] Unique identifier of temporaryAccessPassAuthenticationMethod
        [sr-de] ID der TemporaryAccessPass-AuthenticationMethod
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [Parameter(Mandatory = $true)]
    [string]$MethodId
)

Import-Module Microsoft.Graph.Identity.SignIns

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                    'UserId' = $UserId
                    'TemporaryAccessPassAuthenticationMethodId' = $MethodId
    }
    $null = Remove-MgUserAuthenticationTemporaryAccessPassMethod @cmdArgs -Confirm:$false

    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = "Access pass removed"
    }
    else{
        Write-Output "Access pass removed"
    }    
}
catch{
    throw 
}