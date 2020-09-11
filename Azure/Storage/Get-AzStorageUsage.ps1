#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets the Storage resource usage of the current subscription
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az.Storage

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Storage   

    .Parameter Location
        [sr-en] Get Storage resources usage on the specified location
        [sr-de] Nutzung von Storage Ressourcen der Location abrufen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Location
)

Import-Module Az.Storage

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Location' = $Location
    }
    
    $ret = Get-AzStorageUsage @cmdArgs | Select-Object *

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