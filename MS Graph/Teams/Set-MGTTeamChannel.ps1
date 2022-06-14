#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Updates a team channel
    
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

    .Parameter DisplayName
        [sr-en] Name of the channel
        [sr-de] Kanal Name

    .Parameter Description
        [sr-en] Description of the channel
        [sr-de] Kanal Beschreibung

    .Parameter IsFavoriteByDefault
        [sr-en] Automatically be marked 'favorite' for all members of the team
        [sr-de] Automatisch Favorit für alle Team-Mitglieder
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TeamId,
    [Parameter(Mandatory = $true)]
    [string]$ChannelId,
    [string]$DisplayName,
    [string]$Description,
    [switch]$IsFavoriteByDefault
)

Import-Module Microsoft.Graph.Teams 

try{
    ConnectMSGraph 

    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime','IsFavoriteByDefault')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'TeamID' = $TeamId
                        'ChannelID' = $ChannelId
                        'Confirm' = $false
                        'PassThru' = $null
    }
    if($PSBoundParameters.ContainsKey('DisplayName') -eq $true){
        $cmdArgs.Add('DisplayName',$DisplayName)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($IsFavoriteByDefault.IsPresent -eq $true){
        $cmdArgs.Add('IsFavoriteByDefault',$null)
    }

    $null = Update-MgTeamChannel @cmdArgs
    $mgChannel = Get-MgTeamChannel -TeamId $TeamId -ChannelId $ChannelId | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgChannel
    }
    else{
        Write-Output $mgChannel
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}