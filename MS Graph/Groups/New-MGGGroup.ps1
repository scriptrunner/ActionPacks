#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        Creates a group
    
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

    .PARAMETER DisplayName
        [sr-en] Name of the group
        [sr-de] Gruppenname

    .PARAMETER Description
        [sr-en] Description
        [sr-de] Gruppenbeschreibung

    .PARAMETER AcceptedSenders
        [sr-en] Users or groups that are allowed to create post's or calendar events in this group
        [sr-de] Benutzer oder Gruppen berechtigt für Posts oder Kalendereinträge         

    .PARAMETER AssignedLicenses
        [sr-en] Licenses that are assigned to the group
        [sr-de] Lizenzen der Gruppe

    .PARAMETER Classification
        [sr-en] Group classification
        [sr-de] Gruppenklassifizierung
        
    .Parameter IsAssignableToRole
        [sr-en] Group can be assigned to an Azure Active Directory role
        [sr-de] Gruppe kann zur Azure AD Rolle hinzugefügt werden

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
    [string]$DisplayName,
    [string]$Description,
    [string[]]$AcceptedSenders,        
    [string[]]$AssignedLicenses,
    [ValidateSet('Low','Medium','High')]
    [string]$Classification,
    [switch]$IsAssignableToRole,
    [switch]$Microsoft365Group,
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
    [string]$Visibility = 'Public'
)

Import-Module Microsoft.Graph.Groups 

try{
    ConnectMSGraph 
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime','Mail','MailEnabled')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'Confirm' = $false
                            'DisplayName' =$DisplayName
                            'IsAssignableToRole' = $IsAssignableToRole
                            'MailEnabled' = $MailEnabled
                            'Visibility' = $Visibility
                            'SecurityEnabled' = $SecurityEnabled
    }    
    if($Microsoft365Group.IsPresent){
        $cmdArgs.Add('GroupTypes', @('Unified'))
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
    $mgGroup = New-MgGroup @cmdArgs | Select-Object $Properties

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