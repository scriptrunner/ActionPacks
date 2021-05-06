#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
    .SYNOPSIS
        Updates a custom team template with new team template settings

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module microsoftteams 1.1.1 or greater
        Requires .NET Framework Version 4.7.2.
        Requires a ScriptRunner Microsoft 365 target

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Templates
    
    .Parameter ODataId
        [sr-en] Composite URI of the template
        [sr-de] URI der Vorlage

    .Parameter Name
        [sr-en] Name of the template
        [sr-de] Name der Vorlage
        
    .Parameter ShortDescription
        [sr-en] Template short description
        [sr-de] Kurzbeschreibung des Templates

    .Parameter Description
        [sr-en] The team's Description
        [sr-de] Beschreibung des Templates

    .Parameter Categories
        [sr-en] List of categories
        [sr-de] Kategorienliste

    .Parameter DiscoverySettingShowInTeamsSearchAndSuggestion
        [sr-en] If team is visible within search and suggestions in Teams clients
        [sr-de] Team ist sichtbar in der Suche und den Vorschlägen in Teams-Clients

    .Parameter Icon
        [sr-en] File path and image (.png, .gif, .jpg, or .jpeg)
        [sr-de] Pfad und Name der Bilddatei (.png, .gif, .jpg, oder .jpeg) 

    .Parameter IsMembershipLimitedToOwner
        [sr-en] Limit the membership of the team to owners in the AAD group until an owner "activates" the team
        [sr-de] Die Mitgliedschaft im Team auf Eigentümer in der AAD-Gruppe beschränken, bis ein Eigentümer das Team "aktiviert"

    .Parameter OwnerUser
        [sr-en] User object id of the user who should be set as the owner of the new team
        [sr-de] Benutzer ID des Benutzers, der als Besitzer des neuen Teams gesetzt werden soll

    .Parameter PublishedBy
        [sr-en] Published name
        [sr-de] Veröffentlichungsname

    .Parameter URI
        [sr-en] Template Uri
        [sr-de] Uri des Templates

    .Parameter Visibility
        [sr-en] Control the scope of users who can view a group/team and its members, and ability to join
        [sr-de] Anwendungsbereich von Benutzern, die eine Gruppe/ein Team und deren Mitglieder sehen können, sowie die Möglichkeit, ihnen beizutreten
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ById')]  
    [string]$ODataId,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]  
    [string]$Name,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [string]$ShortDescription,    
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [string[]]$Categories,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [string]$Description,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [switch]$DiscoverySettingShowInTeamsSearchAndSuggestion,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [string]$Icon,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [switch]$IsMembershipLimitedToOwner,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [string]$OwnerUser,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [string]$PublishedBy,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [string]$Uri,
    [Parameter(ParameterSetName = 'ById')]   
    [Parameter(ParameterSetName = 'ByName')]
    [ValidateSet('Private','Public')]
    [string]$Visibility = 'Private'
)

Import-Module microsoftteams

try{
    if($PSCmdlet.ParameterSetName -eq 'ById'){
        $Script:tmp = Get-CsTeamTemplate -OdataId $ODataId -ErrorAction Stop    
        $Name = $Script:tmp.DisplayName    
    }
    else{
        $Script:tmp = (Get-CsTeamTemplateList -ErrorAction Stop) | Where-Object Name -eq $Name
        $ODataId = $Script:tmp.OdataId
    }
    if([System.String]::IsNullOrWhiteSpace($ShortDescription) -eq $true){
        $ShortDescription = $Script:tmp.ShortDescription
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'OdataId' = $ODataId
                            'DisplayName' = $Name
                            'ShortDescription' = $ShortDescription
                            }

    if($PSBoundParameters.ContainsKey('Categories') -eq $true){
        $cmdArgs.Add('Category',$Categories)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('DiscoverySettingShowInTeamsSearchAndSuggestion') -eq $true){
        $cmdArgs.Add('DiscoverySettingShowInTeamsSearchAndSuggestion',$DiscoverySettingShowInTeamsSearchAndSuggestion)
    }
    if($PSBoundParameters.ContainsKey('Icon') -eq $true){
        $cmdArgs.Add('Icon',$Icon)
    }
    if($PSBoundParameters.ContainsKey('IsMembershipLimitedToOwner') -eq $true){
        $cmdArgs.Add('IsMembershipLimitedToOwner',$IsMembershipLimitedToOwner)
    }
    if($PSBoundParameters.ContainsKey('OwnerUser') -eq $true){
        $cmdArgs.Add('OwnerUserObjectId',$OwnerUser)
    }
    if($PSBoundParameters.ContainsKey('PublishedBy') -eq $true){
        $cmdArgs.Add('PublishedBy',$PublishedBy)
    }
    if($PSBoundParameters.ContainsKey('Uri') -eq $true){
        $cmdArgs.Add('Uri',$Uri)
    }
    if($PSBoundParameters.ContainsKey('Visibility') -eq $true){
        $cmdArgs.Add('Visibility',$Visibility)
    }
    
    $null = Update-CsTeamTemplate @cmdArgs
    $result = Get-CsTeamTemplate -OdataId $ODataId -ErrorAction Stop | Select-Object *
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