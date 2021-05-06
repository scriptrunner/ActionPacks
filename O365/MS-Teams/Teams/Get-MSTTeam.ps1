#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Retrieving teams with particular properties/information

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

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams
    
.Parameter GroupId
    [sr-en] GroupId of the team
    [sr-de] Gruppen ID des Teams

.Parameter Archived
    [sr-en] Filters to return teams that have been archived or not
    [sr-de] Archivierte Teams anzeigen

.Parameter DisplayName
    [sr-en] Filters to return teams with a full match to the provided displayname
    [sr-de] Anzeigename des Teams

.Parameter MailNickName
    [sr-en] Specify the mailnickname of the team that is being returned
    [sr-de] Mail-Nickname des Teams

.Parameter Visibility
    [sr-en] Filters to return teams with a set "visibility" value
    [sr-de] Nur sichtbare Teams
    
.Parameter Properties
    [sr-en] List of properties to expand. Use * for all properties
    [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

[CmdLetBinding()]
Param(
    [string]$GroupId,
    [bool]$Archived,
    [string]$DisplayName,
    [string]$MailNickName,
    [ValidateSet('Public','Private')]
    [string]$Visibility,
    [ValidateSet('*','GroupId','DisplayName','Description','Visibility','MailNickName','Archived')]
    [string[]]$Properties = @('GroupId','DisplayName','Description','Visibility','MailNickName','Archived')
)

Import-Module microsoftteams

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'Archived' = $Archived
                            }  
                            
    if([System.String]::IsNullOrWhiteSpace($GroupId) -eq $false){
        $getArgs.Add('GroupId',$GroupId)
    }
    if([System.String]::IsNullOrWhiteSpace($DisplayName) -eq $false){
        $getArgs.Add('DisplayName',$DisplayName)
    }
    if([System.String]::IsNullOrWhiteSpace($MailNickName) -eq $false){
        $getArgs.Add('MailNickName',$MailNickName)
    }
    if([System.String]::IsNullOrWhiteSpace($Visibility) -eq $false){
        $getArgs.Add('Visibility',$Visibility)
    }

    $result = Get-Team @getArgs | Sort-Object DisplayName | Select-Object $Properties 
    
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