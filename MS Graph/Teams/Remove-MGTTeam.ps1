#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams,Microsoft.Graph.Groups

<#
    .SYNOPSIS
        Removes a Team
    
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
        Requires Modules Microsoft.Graph.Teams, Microsoft.Graph.Groups 

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
Import-Module Microsoft.Graph.Groups 

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'TeamID' = $TeamId
                        'Confirm' = $false
    }
  #  $result = Remove-MgTeam @cmdArgs erroneous in v1.9.2
    $result = Remove-MgGroup -GroupId $TeamId -Confirm:$false -ErrorAction Stop

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