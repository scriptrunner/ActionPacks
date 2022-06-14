#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Removes a member from the team
    
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
        Requires Modules Microsoft.Graph.Teams 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Teams

    .Parameter TeamId
        [sr-en] Team identifier
        [sr-de] Team ID

    .Parameter MemberId
        [sr-en] Member identifier
        [sr-de] ID des Mitglieds
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TeamId,
    [Parameter(Mandatory = $true)]
    [string]$MemberId
)

Import-Module Microsoft.Graph.Teams 

try{
    [string[]]$Properties = @('DisplayName','Id','Roles')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'TeamID' = $TeamId
                        'ConversationMemberId' = $MemberId
                        'Confirm' = $false
    }

    ConnectMSGraph 
    $null = Remove-MgTeamMember @cmdArgs
    $mgMembers = Get-MgTeamMember -TeamID $TeamId | Sort-Object DisplayName | Select-Object $Properties 
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgMembers
    }
    else{
        Write-Output $mgMembers
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}