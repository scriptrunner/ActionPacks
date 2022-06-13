#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Updates a team channel tab
    
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

    .Parameter ChannelId
        [sr-en] Id of channel
        [sr-de] Kanal ID

    .Parameter TabId
        [sr-en] Id of teams tab
        [sr-de] Kanal Tab ID

    .Parameter DisplayName
        [sr-en] Name of the tab
        [sr-de] Tab Name
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TeamId,
    [Parameter(Mandatory = $true)]
    [string]$ChannelId,
    [Parameter(Mandatory = $true)]
    [string]$TabId,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName
)

Import-Module Microsoft.Graph.Teams 

try{
    [string[]]$Properties = @('DisplayName','Id','WebUrl')
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'TeamID' = $TeamId
                        'ChannelID' = $ChannelId
                        'TeamsTabId' = $TabId
    }

    $null = Update-MgTeamChannelTab @cmdArgs -Confirm:$false -DisplayName $DisplayName
    $mgTab = Get-MgTeamChannelTab @cmdArgs | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgTab
    }
    else{
        Write-Output $mgTab
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}