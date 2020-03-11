#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.4"}

<#
.SYNOPSIS
    Creates a new Team for use in Microsoft Teams and will create an O365 Unified Group to back the team

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
    Requires Library script MSTLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials
    
.Parameter DisplayName
    Team display name

.Parameter Description
    Team Description

.Parameter AllowAddRemoveApps
    Determines whether or not members (not only owners) are allowed to add apps to the team

.Parameter MailNickName
    The MailNickName parameter specifies the alias for the associated Office 365 Group. 
    The value of the MailNickName parameter has to be unique across your tenant.

.Parameter Visibility
    Set to Public to allow all users in your organization to join the group by default. 
    Set to Private to require that an owner approve the join request

.Parameter AllowChannelMentions
    Determines whether or not channels in the team can be @ mentioned so that all users who follow the channel are notified

.Parameter AllowCreateUpdateChannels
    Determines whether or not members (and not just owners) are allowed to create channels

.Parameter AllowCreateUpdateRemoveConnectors
    Determines whether or not members (and not only owners) can manage connectors in the team

.Parameter AllowCreateUpdateRemoveTabs
    Determines whether or not members (and not only owners) can manage tabs in channels

.Parameter AllowCustomMemes
    Determines whether or not members can use the custom memes functionality in teams

.Parameter AllowDeleteChannels
    Determines whether or not members (and not only owners) can delete channels in the team

.Parameter AllowGiphy
    Determines whether or not giphy can be used in the team

.Parameter AllowGuestCreateUpdateChannels
    Determines whether or not guests can create channels in the team

.Parameter AllowGuestDeleteChannels
    Determines whether or not guests can delete in the team

.Parameter AllowOwnerDeleteMessages
    Determines whether or not owners can delete messages that they or other members of the team have posted

.Parameter AllowStickersAndMemes
    Determines whether stickers and memes usage is allowed in the team

.Parameter AllowTeamMentions
    Determines whether the entire team can be @ mentioned (which means that all users will be notified)    

.Parameter AllowUserDeleteMessages
    Determines whether or not members can delete messages that they have posted   
    
.Parameter AllowUserEditMessages
    Determines whether or not users can edit messages that they have posted

.Parameter GiphyContentRating
    Determines the level of sensitivity of giphy usage that is allowed in the team

.Parameter Owner
    An admin who is allowed to create on behalf of another user should use this flag to specify the desired owner of the group
   
.Parameter Users
    One or more User UPN's (user principal name) to be added to the team as a member

.Parameter Channels
    One or more channel display names, comma separated

.Parameter ShowInTeamsSearchAndSuggestions
    Determines whether or not private teams should be searchable from Teams clients for users who do not belong to that team

.Parameter RetainCreatedGroup 
    Allow toggle of group cleanup if team creation fails

.Parameter TenantID
    Specifies the ID of a tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$MSTCredential,
    [Parameter(Mandatory = $true)]   
    [ValidateLength(5,256)]
    [string]$DisplayName,
    [ValidateLength(0,1024)]
    [string]$Description,
    [ValidateSet('Public','Private')]
    [string]$Visibility,
    [string]$MailNickName,
    [bool]$AllowAddRemoveApps,
    [bool]$AllowChannelMentions,
    [bool]$AllowCreateUpdateChannels,
    [bool]$AllowCreateUpdateRemoveConnectors,
    [bool]$AllowCreateUpdateRemoveTabs,
    [bool]$AllowCustomMemes,
    [bool]$AllowDeleteChannels,
    [bool]$AllowGuestCreateUpdateChannels,
    [bool]$AllowGiphy,
    [bool]$AllowGuestDeleteChannels,
    [bool]$AllowOwnerDeleteMessages,
    [bool]$AllowStickersAndMemes,
    [bool]$AllowTeamMentions,
    [bool]$AllowUserDeleteMessages,
    [bool]$AllowUserEditMessages,
    [bool]$ShowInTeamsSearchAndSuggestions,
    [string]$Owner,    
    [string[]]$Users,    
    [string]$Channels,    
    [ValidateSet('Strict','Moderate')]
    [string]$GiphyContentRating,
    [switch]$RetainCreatedGroup,
    [string]$TenantID
)

Import-Module microsoftteams

try{
    [string]$version = (Get-Module microsoftteams | Select-Object Version).Version
    [string[]]$Global:Properties = @('DisplayName','GroupId')
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    [hashtable]$Global:cmdArgs = @{'ErrorAction' = 'Stop'}  
    $cmdArgs.Add('DisplayName',$DisplayName)
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
    if([System.String]::IsNullOrWhiteSpace($Owner) -eq $false){
        $Global:cmdArgs.Add('Owner',$Owner)
        $Global:Properties += 'Owner'
    }   
    
    FillParameters -BoundParameters $PSBoundParameters
    $result = @()
    $cmdArgs.Add('RetainCreatedGroup',$RetainCreatedGroup)
    $team = New-Team @Global:cmdArgs | Select-Object $Global:Properties
    
    $result += $team
    $result += ' '

    # add users to team
    if(($null -ne $Users) -and ($users.Length -gt 0)){
        foreach($usr in $Users){
            try{
                $null = Add-TeamUser -User $usr -GroupId $team.GroupId -Role Member -ErrorAction Stop
                $result += "User $($usr) added to team $($team.Displayname)"
            }
            catch{
                $result += "Error. Add user $($usr) to team $($team.Displayname)"
            }
        } 
    }
    # add channels to team
    if(($null -ne $Channels) -and ($Channels.Length -gt 0)){
        $names = $Channels.Split(',')
        foreach($cnl in $names){
            try{
                $null = New-TeamChannel -GroupId $team.GroupId -DisplayName $cnl -ErrorAction Stop
                $result += "Channel $($cnl) added to team $($team.Displayname)"
            }
            catch{
                $result += "Error. Add channel $($cnl) to team $($team.Displayname)"
            }
        }  
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
    DisconnectMSTeams
}