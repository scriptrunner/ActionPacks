#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Updates properties of a team

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams
    Requires a ScriptRunner Microsoft 365 target
    Requires Library script MSTLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams

.Parameter GroupId
    [sr-en] GroupId of the team
    [sr-de] Gruppen ID des Teams
    
.Parameter DisplayName
    [sr-en] Team display name
    [sr-de] Anzeigename

.Parameter Description
    [sr-en] Team Description
    [sr-de] Beschreibung des Teams

.Parameter AllowAddRemoveApps
    [sr-en] Determines whether or not members (not only owners) are allowed to add apps to the team
    [sr-de] Mitglieder (nicht nur Besitzer) dürfen Apps zum Team hinzufügen 

.Parameter MailNickName
    [sr-en] The MailNickName parameter specifies the alias for the associated Office 365 Group. 
    The value of the MailNickName parameter has to be unique across your tenant.
    [sr-de] Alias für die zugeordnete Office 365-Gruppe.
    Der MailNickName muss für den Mandanten eindeutig sein.

.Parameter Visibility
    [sr-en] Set to Public to allow all users in your organization to join the group by default. 
    Set to Private to require that an owner approve the join request
    [sr-de] Public damit alle Benutzer in der Organisation der Gruppe standardmäßig beitreten können. 
    Private falls ein Besitzer die Beitrittsanforderung genehmigen muss.

.Parameter AllowChannelMentions
    [sr-en] Determines whether or not channels in the team can be @ mentioned so that all users who follow the channel are notified
    [sr-de] Kanäle können im Team erwähnt werden 

.Parameter AllowCreateUpdateChannels
    [sr-en] Determines whether or not members (and not just owners) are allowed to create channels
    [sr-de] Mitglieder (und nicht nur Besitzer) dürfen Kanäle erstellen 

.Parameter AllowCreateUpdateRemoveConnectors
    [sr-en] Determines whether or not members (and not only owners) can manage connectors in the team
    [sr-de] Mitglieder (und nicht nur Besitzer) können Connectors im Team verwalten

.Parameter AllowCreateUpdateRemoveTabs
    [sr-en] Determines whether or not members (and not only owners) can manage tabs in channels
    [sr-de] Mitglieder (und nicht nur Besitzer) können Registerkarten in Kanälen verwalten

.Parameter AllowCustomMemes
    [sr-en] Determines whether or not members can use the custom memes functionality in teams
    [sr-de] Mitglieder können die benutzerdefinierte Meme-Funktionalität in Teams verwenden

.Parameter AllowDeleteChannels
    [sr-en] Determines whether or not members (and not only owners) can delete channels in the team
    [sr-de] Mitglieder (und nicht nur Besitzer) können Kanäle im Team löschen

.Parameter AllowGiphy
    [sr-en] Determines whether or not giphy can be used in the team
    [sr-de] Giphy kann im Team verwendet werden 

.Parameter AllowGuestCreateUpdateChannels
    [sr-en] Determines whether or not guests can create channels in the team
    [sr-de] Gäste können Kanäle im Team erstellen

.Parameter AllowGuestDeleteChannels
    [sr-en] Determines whether or not guests can delete in the team
    [sr-de] Gäste können im Team gelöscht werden 

.Parameter AllowOwnerDeleteMessages
    [sr-en] Determines whether or not owners can delete messages that they or other members of the team have posted
    [sr-de] Besitzer können Nachrichten löschen 

.Parameter AllowStickersAndMemes
    [sr-en] Determines whether stickers and memes usage is allowed in the team
    [sr-de] Verwendung von Aufklebern und Memes im Team ist zulässig 

.Parameter AllowTeamMentions
    [sr-en] Determines whether the entire team can be @ mentioned (which means that all users will be notified)    
    [sr-de] Das gesamte Team kann erwähnt werden kann

.Parameter AllowUserDeleteMessages
    [sr-en] Determines whether or not members can delete messages that they have posted   
    [sr-de] Benutzer können Nachrichten löschen
    
.Parameter AllowUserEditMessages
    [sr-en] Determines whether or not users can edit messages that they have posted
    [sr-de] Benutzer können Nachrichten bearbeiten

.Parameter GiphyContentRating
    [sr-en] Determines the level of sensitivity of giphy usage that is allowed in the team
    [sr-de] Zulässiger Sensitivitätsgrad der Giphy-Nutzung

.Parameter ShowInTeamsSearchAndSuggestions
    [sr-en] Determines whether or not private teams should be searchable from Teams clients for users who do not belong to that team
    [sr-de] Private Teams können von Teams-Clients nach Benutzern durchsucht werden
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$MSTCredential,
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [ValidateLength(5,256)]
    [string]$DisplayName,
    [ValidateLength(0,1024)]
    [string]$Description,
    [string]$MailNickName,
    [ValidateSet('Public','Private')]
    [string]$Visibility,
    [bool]$AllowAddRemoveApps,    
    [bool]$AllowChannelMentions,    
    [bool]$AllowCreateUpdateChannels,
    [bool]$AllowCreateUpdateRemoveConnectors,    
    [bool]$AllowCreateUpdateRemoveTabs,
    [bool]$AllowCustomMemes,    
    [bool]$AllowDeleteChannels,
    [bool]$AllowGiphy,    
    [bool]$AllowGuestCreateUpdateChannels,    
    [bool]$AllowGuestDeleteChannels,    
    [bool]$AllowOwnerDeleteMessages,
    [bool]$AllowStickersAndMemes,
    [bool]$AllowTeamMentions,
    [bool]$AllowUserDeleteMessages,
    [bool]$AllowUserEditMessages,
    [ValidateSet('Strict','Moderate')]
    [string]$GiphyContentRating,
    [bool]$ShowInTeamsSearchAndSuggestions,
    [string]$TenantID
)

Import-Module microsoftteams

try{
    [string[]]$Global:Properties = @('DisplayName','GroupId')

    [hashtable]$Global:cmdArgs = @{'ErrorAction' = 'Stop'
                                    'GroupId' = $GroupId
                                }  
    if([System.String]::IsNullOrWhiteSpace($DisplayName) -eq $false){
        $Global:cmdArgs.Add('DisplayName',$DisplayName)
    } 
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
        $Global:cmdArgs.Add('Description',$Description)
        $Global:Properties += 'Description'
    }    
    if([System.String]::IsNullOrWhiteSpace($MailNickName) -eq $false){
        $Global:cmdArgs.Add('MailNickName',$MailNickName)
        $Global:Properties += 'MailNickName'
    }
    if([System.String]::IsNullOrWhiteSpace($Visibility) -eq $false){
        $Global:cmdArgs.Add('Visibility',$Visibility)
        $Global:Properties += 'Visibility'
    }   
    if([System.String]::IsNullOrWhiteSpace($GiphyContentRating) -eq $false){
        $Global:cmdArgs.Add('GiphyContentRating',$GiphyContentRating)
        $Global:Properties += 'GiphyContentRating'
    }    
    
    FillParameters -BoundParameters $PSBoundParameters
    $result = Set-Team @Global:cmdArgs | Select-Object $Global:Properties
    
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