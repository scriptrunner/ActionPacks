﻿#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Returns groups of user or contact
    
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
        Requires Modules Microsoft.Graph.Identity.DirectoryManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Contacts

    .Parameter ContactId
        [sr-en] Identifier of the contact
        [sr-de] Kontakt-ID

    .Parameter SecurityEnabledOnly
        [sr-en] Member must be a user or service principal
        [sr-de] Mitglied muss ein Benutzer oder Service principal sein
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ContactId,
    [switch]$SecurityEnabledOnly
)          

Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'OrgContactId' = $ContactId
                        'SecurityEnabledOnly' = $SecurityEnabledOnly.IsPresent
    }
    $result = Get-MgContactMemberGroup @cmdArgs
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