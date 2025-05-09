﻿#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Returns DNS records the customer adds to the DNS zone file of the domain before the domain can be used
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Domain

    .Parameter DomainId
        [sr-en] Identifier of the domain
        [sr-de] ID der Domäne
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$DomainId
)

Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                    'DomainId' = $DomainId
    }
    $result = Get-MgDomainServiceConfigurationRecord @cmdArgs | Select-Object *

    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction Ignore) {
        ConvertTo-ResultHtml -Result $result
    }
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