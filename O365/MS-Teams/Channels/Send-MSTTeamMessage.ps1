#Requires -Version 5.0

<#
.SYNOPSIS
    Publish a message in a Microsoft Teams channel 

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

.Parameter WebhookURL
    The URL of your Webhook, it must be match with "https://outlook.office.com/webhook/"
    
.Parameter Message
    The body of the message to publish on Teams

.Parameter Title
    The Title of the message to publish on Teams

.Parameter MessageColor
    The color theme for the message

.Parameter ActivityTitle
    The Activity title of the message to publish on Teams

.Parameter ActivitySubtitle
    The Activity subtitle of the message to publish on Teams
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [ValidatePattern("^https://outlook.office.com/webhook/*")]
    [string]$WebhookURL,
    [Parameter(Mandatory = $true)]   
    [string]$Message,
    [string]$Title,
    [ValidateSet('Orange','Green','Red')]
    [string]$MessageColor,
    [string]$ActivityTitle,
    [string]$ActivitySubtitle
)

try{    
    try{ 
        # Send the request to Microsoft Teams 
        SendMessage2Channel -WebhookURL $WebhookURL -Message $Message -Title $Title `
                -MessageColor $MessageColor -ActivityTitle $ActivityTitle -ActivitySubtitle $ActivitySubtitle
    }
    catch{
        throw "Error! Impossible to publish this message in Microsoft Teams!"
    }     
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Message send to Microsoft Teams"
    }
    else{
        Write-Output "Message send to Microsoft Teams"
    }
}
catch{
    throw
}
finally{
}