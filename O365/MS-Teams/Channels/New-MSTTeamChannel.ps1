#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Add a new channel to a team

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Channels
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials 

.Parameter WebhookURL
    The URL of your Webhook, it must be match with "https://outlook.office.com/webhook/"
    
.Parameter Message
    The body of the message to publish on Teams

.Parameter Title
    The Title of the message to publish on Teams

.Parameter MessageColor
    The color theme for the message

.Parameter TenantID
    Specifies the ID of a tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$MSTCredential,
    [Parameter(Mandatory = $true)]   
    [string]$WebhookURL,
    [Parameter(Mandatory = $true)]   
    [ValidatePattern("^https://outlook.office.com/webhook/*")]
    [string]$Message,
    [string]$Title,
    [ValidateSet('Orange','Green','Red')]
    [string]$MessageColor,
    [string]$TenantID
)

Import-Module microsoftteams

try{
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'DisplayName' = $DisplayName
                            'GroupId' = $GroupId
                            }      
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
        $cmdArgs.Add('Description',$Description)
    }    
    $result = New-TeamChannel @cmdArgs | Select-Object *
    
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