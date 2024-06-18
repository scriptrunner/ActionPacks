#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Creates a Team
    
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
                
    .Parameter DisplayName
        [sr-en] Display name of the team
        [sr-de] Team Anzeigename

    .Parameter TeamOwner
        [sr-en] Owner of the team (UPN)
        [sr-de] Besitzer des Teams (UPN)
        
    .Parameter Description
        [sr-en] Description of the team
        [sr-de] Team Beschreibung

    .Parameter AllowAddRemoveApps
        [sr-en] Determines whether or not members (not only owners) are allowed to add apps to the team
        [sr-de] Mitglieder (nicht nur Besitzer) dürfen Apps zum Team hinzufügen 

    .Parameter AllowCreateUpdateChannels
        [sr-en] Determines whether or not members (and not just owners) are allowed to create channels
        [sr-de] Mitglieder (und nicht nur Besitzer) dürfen Kanäle erstellen 

    .Parameter AllowCreateUpdateRemoveConnectors
        [sr-en] Determines whether or not members (and not only owners) can manage connectors in the team
        [sr-de] Mitglieder (und nicht nur Besitzer) können Connectors im Team verwalten

    .Parameter AllowCreateUpdateRemoveTabs
        [sr-en] Determines whether or not members (and not only owners) can manage tabs in channels
        [sr-de] Mitglieder (und nicht nur Besitzer) können Registerkarten in Kanälen verwalten

    .Parameter AllowDeleteChannels
        [sr-en] Determines whether or not members (and not only owners) can delete channels in the team
        [sr-de] Mitglieder (und nicht nur Besitzer) können Kanäle im Team löschen 

    .Parameter AllowGuestCreateUpdateChannels
        [sr-en] Determines whether or not guests can create channels in the team
        [sr-de] Gäste können Kanäle im Team erstellen

    .Parameter AllowGuestDeleteChannels
        [sr-en] Determines whether or not guests can delete in the team
        [sr-de] Gäste können im Team gelöscht werden 

    .Parameter AllowGiphy
        [sr-en] Determines whether or not giphy can be used in the team
        [sr-de] Giphy kann im Team verwendet werden 

    .Parameter AllowStickersAndMemes
        [sr-en] Determines whether stickers and memes usage is allowed in the team
        [sr-de] Verwendung von Aufklebern und Memes im Team ist zulässig 

    .Parameter AllowCustomMemes
        [sr-en] Determines whether or not members can use the custom memes functionality in teams
        [sr-de] Mitglieder können die benutzerdefinierte Meme-Funktionalität in Teams verwenden

    .Parameter AllowTeamMentions
        [sr-en] Determines whether the entire team can be @ mentioned (which means that all users will be notified)    
        [sr-de] Das gesamte Team kann erwähnt werden kann

    .Parameter AllowChannelMentions
        [sr-en] Determines whether or not channels in the team can be @ mentioned so that all users who follow the channel are notified
        [sr-de] Kanäle können im Team erwähnt werden 

    .Parameter AllowOwnerDeleteMessages
        [sr-en] Determines whether or not owners can delete messages that they or other members of the team have posted
        [sr-de] Besitzer können Nachrichten löschen 

    .Parameter AllowUserDeleteMessages
        [sr-en] Determines whether or not members can delete messages that they have posted   
        [sr-de] Benutzer können Nachrichten löschen
        
    .Parameter AllowUserEditMessages
        [sr-en] Determines whether or not users can edit messages that they have posted
        [sr-de] Benutzer können Nachrichten bearbeiten

    .Parameter GiphyContentRating
        [sr-en] Determines the level of sensitivity of giphy usage that is allowed in the team
        [sr-de] Zulässiger Sensitivitätsgrad der Giphy-Nutzung

    .Parameter Visibility
        [sr-en] Team visibility type
        [sr-de] Team Typ  
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true)]
    [string]$TeamOwner,
    [string]$Description,        
    [bool]$AllowAddRemoveApps,
    [bool]$AllowCreateUpdateChannels,
    [bool]$AllowDeleteChannels,
    [bool]$AllowCreateUpdateRemoveConnectors,
    [bool]$AllowCreateUpdateRemoveTabs,
    [bool]$AllowGuestCreateUpdateChannels,
    [bool]$AllowGuestDeleteChannels,
    [bool]$AllowCustomMemes,
    [bool]$AllowGiphy,
    [bool]$AllowStickersAndMemes,
    [bool]$AllowTeamMentions,
    [bool]$AllowChannelMentions,
    [bool]$AllowOwnerDeleteMessages,
    [bool]$AllowUserEditMessages,
    [bool]$AllowUserDeleteMessages,
    [ValidateSet('Strict','Moderate')]
    [string]$GiphyContentRating,
    [Validateset('Public','Private')]
    [string]$Visibility = 'Public'
)

Import-Module Microsoft.Graph.Teams 

try{
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'DisplayName' = $DisplayName
                        'Visibility' = $Visibility
                        'Confirm' = $false
                        'AdditionalProperties' = @{
                            "template@odata.bind" = "https://graph.microsoft.com/beta/teamsTemplates('standard')"
                        }
                        'Members' = @(
                            @{
                                "@odata.type" = "#microsoft.graph.aadUserConversationMember"
                                Roles = @(
                                    "owner"
                                )
                                "User@odata.bind" = "https://graph.microsoft.com/v1.0/users('$($TeamOwner)')" 
                            })
                        'MemberSettings' = @{
                            'AllowAddRemoveApps' = $AllowAddRemoveApps
                            'AllowCreateUpdateChannels' = $AllowCreateUpdateChannels
                            'AllowDeleteChannels' = $AllowDeleteChannels
                            'AllowCreateUpdateRemoveConnectors' = $AllowCreateUpdateRemoveConnectors
                            'AllowCreateUpdateRemoveTabs' = $AllowCreateUpdateRemoveTabs
                        }
                        'GuestSettings' = @{
                            'AllowGuestCreateUpdateChannels' = $AllowGuestCreateUpdateChannels
                            'AllowGuestDeleteChannels' = $AllowGuestDeleteChannels
                        }
                        'FunSettings' = @{          
                            'AllowGiphy' = $AllowGiphy
                            'AllowCustomMemes' = $AllowCustomMemes
                            'AllowStickersAndMemes' = $AllowStickersAndMemes                  
                            'GiphyContentRating' = 'Moderate'
                        }
                        'MessagingSettings' = @{          
                            'AllowOwnerDeleteMessages' = $AllowOwnerDeleteMessages
                            'AllowUserEditMessages' = $AllowUserEditMessages
                            'AllowUserDeleteMessages' = $AllowUserDeleteMessages
                            'AllowChannelMentions' = $AllowChannelMentions                  
                            'AllowTeamMentions' = $AllowTeamMentions
                        }
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    $mgTeam = New-MgTeam @cmdArgs | Select-Object $Properties # erroneous in v1.27

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgTeam
    }
    else{
        Write-Output $mgTeam
    }
}
catch{
    throw 
}
finally{    
}