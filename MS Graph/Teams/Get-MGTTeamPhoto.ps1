#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams

<#
    .SYNOPSIS
        Get photo from teams
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Teams

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Teams

    .Parameter TeamId
        [sr-en] Team identifier
        [sr-de] Team ID
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TeamId
)

Import-Module Microsoft.Graph.Teams

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'TeamId' = $TeamId
    }
    $result = Get-MgTeamPhoto @cmdArgs

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