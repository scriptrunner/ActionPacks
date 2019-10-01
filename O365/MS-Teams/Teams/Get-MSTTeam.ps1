#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Retrieving teams with particular properties/information

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module microsoftteams
    Requires Library script MSTLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials
    
.Parameter GroupId
    Specify the specific GroupId of the team to be returned

.Parameter Archived
    Filters to return teams that have been archived or not

.Parameter DisplayName
    Filters to return teams with a full match to the provided displayname

.Parameter MailNickName
    Specify the mailnickname of the team that is being returned

.Parameter Visibility
    Filters to return teams with a set "visibility" value
    
.Parameter Properties
    List of comma separated properties to expand. Use * for all properties

.Parameter TenantID
    Specifies the ID of a tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$MSTCredential,
    [string]$GroupId,
    [bool]$Archived,
    [string]$DisplayName,
    [string]$MailNickName,
    [ValidateSet('Public','Private')]
    [string]$Visibility,
    [string]$Properties = "GroupId,DisplayName,Description,Visibility,MailNickName,Archived",
    [string]$TenantID
)

Import-Module microsoftteams

try{
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties = '*'
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

    $result = Get-Team @getArgs | Select-Object $Properties.Split(',')  
    
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