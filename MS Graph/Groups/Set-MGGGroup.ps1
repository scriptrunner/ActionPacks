#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        Updates a group
    
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
        Requires Modules Microsoft.Graph.Groups 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Groups

    .PARAMETER GroupId
        [sr-en] Identifier of the group
        [sr-de] Gruppen-ID

    .PARAMETER Description
        [sr-en] Description
        [sr-de] Gruppenbeschreibung

    .PARAMETER AcceptedSenders
        [sr-en] Users or groups that are allowed to create post's or calendar events in this group
        [sr-de] Benutzer oder Gruppen berechtigt für Posts oder Kalendereinträge 

    .Parameter AllowExternalSenders
        [sr-en] People external to the organization can send messages to the group
        [sr-de] Personen außerhalb der Organisation können Nachrichten an die Gruppe senden

    .PARAMETER AssignedLicenses
        [sr-en] Licenses that are assigned to the group
        [sr-de] Lizenzen der Gruppe

    .Parameter AutoSubscribeNewMembers
        [sr-en] New members will be auto-subscribed to receive email notifications
        [sr-de] Neue Mitglieder werden automatisch für den Erhalt von E-Mail-Benachrichtigungen angemeldet.

    .PARAMETER Classification
        [sr-en] Group classification
        [sr-de] Gruppenklassifizierung
        
    .Parameter HideFromAddressLists
        [sr-en] Group is not displayed in certain parts of the Outlook UI
        [sr-de] Gruppe wird in bestimmten Teilen der Outlook-Benutzeroberfläche nicht angezeigt
        
    .Parameter HideFromOutlookClients
        [sr-en] Group is not displayed in Outlook clients
        [sr-de] Gruppe wird nicht in Outlook angezeigt

    .Parameter IsArchived
        [sr-en] Archived
        [sr-de] Archiviert
        
    .Parameter IsAssignableToRole
        [sr-en] Group can be assigned to an Azure Active Directory role
        [sr-de] Gruppe kann zur Azure AD Rolle hinzugefügt werden
        
    .Parameter IsSubscribedByMail
        [sr-en] Signed-in user is subscribed to receive email conversations
        [sr-de] Angemeldeter Benutzer ist für den Empfang von E-Mail-Konversationen abonniert

    .PARAMETER Mail
        [sr-en] SMTP address for the group
        [sr-de] SMTP Adresse der Gruppe

    .PARAMETER MailEnabled
        [sr-en] Group is mail-enabled
        [sr-de] Mailing

    .PARAMETER MailNickname
        [sr-en] Mail alias for the group
        [sr-de] Mail-Alias der Gruppe

    .PARAMETER MemberOf
        [sr-en] Groups that this group is a member of
        [sr-de] Gruppen Mitgliedschaften

    .PARAMETER Members
        [sr-en] Users and groups that are members of this group
        [sr-de] Benutzer und Gruppen Mitglieder 

    .PARAMETER Owners
        [sr-en] Owners of the group
        [sr-de] Gruppenbesitzer

    .PARAMETER PreferredLanguage
        [sr-en] Preferred language for the group
        [sr-de] Sprache der Gruppe

    .PARAMETER RejectedSenders
        [sr-en] Users or groups that are not allowed to create posts or calendar events in this group
        [sr-de] Benutzer oder Gruppen die nicht berechtigt für Posts oder Kalendereinträge 

    .PARAMETER SecurityEnabled
        [sr-en] Group is a security group
        [sr-de] Security-Gruppe

    .PARAMETER Microsoft365Group
        [sr-en] Group is a Microsoft 365 group
        [sr-de] M365-Gruppe

    .PARAMETER Theme
        [sr-en] Group's color theme
        [sr-de] Gruppen Farbschema

    .Parameter Visibility
        [sr-en] Group visibility type
        [sr-de] Typ der Gruppe  
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [string]$Description,
    [string[]]$AcceptedSenders,
    [switch]$AllowExternalSenders,
    [string[]]$AssignedLicenses,
    [switch]$AutoSubscribeNewMembers,
    [switch]$Microsoft365Group,
    [ValidateSet('Low','Medium','High')]
    [string]$Classification,
    [switch]$HideFromAddressLists,
    [switch]$HideFromOutlookClients,
    [switch]$IsArchived,
    [switch]$IsAssignableToRole,
    [switch]$IsSubscribedByMail,
    [string]$Mail,
    [string]$MailNickname,
    [string[]]$MemberOf,
    [string[]]$Members,
    [string[]]$Owners,
    [ValidateSet('en-US','de-DE')]
    [string]$PreferredLanguage,
    [switch]$MailEnabled,
    [string[]]$RejectedSenders,
    [switch]$SecurityEnabled,
    [Validateset('Teal','Purple','Green','Blue','Pink','Orange','Red')]
    [string]$Theme,
    [Validateset('Public','Private')]
    [string]$Visibility
)

Import-Module Microsoft.Graph.Groups 

try{
    ConnectMSGraph 
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime','Mail','MailEnabled')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'Confirm' = $false
                            'PassThru' = $null
                            'GroupId' = $GroupId
    }
    if($Microsoft365Group.IsPresent){
        $cmdArgs.Add('GroupTypes', @('Unified'))
    }
    if($AllowExternalSenders.IsPresent) {
        $cmdArgs.Add('AllowExternalSenders' ,$AllowExternalSenders)
    }
    if($AutoSubscribeNewMembers.IsPresent) {
        $cmdArgs.Add('AutoSubscribeNewMembers' ,$AutoSubscribeNewMembers)
    }
    if($HideFromOutlookClients.IsPresent) {
        $cmdArgs.Add('HideFromOutlookClients' ,$HideFromOutlookClients)
    }
    if($HideFromAddressLists.IsPresent) {
        $cmdArgs.Add('HideFromAddressLists' ,$HideFromAddressLists)
    }
    if($IsSubscribedByMail.IsPresent) {
        $cmdArgs.Add('IsSubscribedByMail' ,$IsSubscribedByMail)
    }
    if($MailEnabled.IsPresent) {
        $cmdArgs.Add('MailEnabled' ,$MailEnabled)
    }
    if($IsAssignableToRole.IsPresent) {
        $cmdArgs.Add('IsAssignableToRole' ,$IsAssignableToRole)
    }
    if($IsArchived.IsPresent) {
        $cmdArgs.Add('IsArchived' ,$IsArchived)
    }
    if($SecurityEnabled.IsPresent) {
        $cmdArgs.Add('SecurityEnabled' ,$SecurityEnabled)
    }
    if($PSBoundParameters.ContainsKey('AcceptedSenders') -eq $true){
        $cmdArgs.Add('AcceptedSenders',$AcceptedSenders)
    }
    if($PSBoundParameters.ContainsKey('AssignedLicenses') -eq $true){
        $cmdArgs.Add('AssignedLicenses',$AssignedLicenses)
    }
    if($PSBoundParameters.ContainsKey('Classification') -eq $true){
        $cmdArgs.Add('Classification',$Classification)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('Mail') -eq $true){
        $cmdArgs.Add('Mail',$Mail)
    }
    if($PSBoundParameters.ContainsKey('MailNickname') -eq $true){
        $cmdArgs.Add('MailNickname',$MailNickname)
    }
    if($PSBoundParameters.ContainsKey('MemberOf') -eq $true){
        $cmdArgs.Add('MemberOf',$MemberOf)
    }
    if($PSBoundParameters.ContainsKey('Members') -eq $true){
        $cmdArgs.Add('Members',$Members)
    }
    if($PSBoundParameters.ContainsKey('Owners') -eq $true){
        $cmdArgs.Add('Owners',$Owners)
    }
    if($PSBoundParameters.ContainsKey('PreferredLanguage') -eq $true){
        $cmdArgs.Add('PreferredLanguage',$PreferredLanguage)
    }
    if($PSBoundParameters.ContainsKey('RejectedSenders') -eq $true){
        $cmdArgs.Add('RejectedSenders',$RejectedSenders)
    }
    if($PSBoundParameters.ContainsKey('Theme') -eq $true){
        $cmdArgs.Add('Theme',$Theme)
    }
    if($PSBoundParameters.ContainsKey('Visibility') -eq $true){
        $cmdArgs.Add('Visibility',$Visibility)
    }
    $mgGroup = Update-MgGroup @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgGroup
    }
    else{
        Write-Output $mgGroup
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}