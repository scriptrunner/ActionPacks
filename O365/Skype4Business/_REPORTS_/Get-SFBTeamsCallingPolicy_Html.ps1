#Requires -Version 5.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Generates a report with information about the teams calling policies configured for use in your organization
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module SkypeOnlineConnector
        Requires Library script SFBLibrary.ps1
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/_REPORTS_

    .Parameter SFBCredential
        [sr-en] Credential object containing the Skype for Business user/password
        [sr-de] Benutzername und Passwort für die Anmeldung

    .Parameter Identity
        [sr-en] Specify the TeamsCallingPolicy
        [sr-de] Gibt die Teams Calling Policy an
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [string]$Identity
)

Import-Module SkypeOnlineConnector

try{
    [string[]]$Properties = @('Identity','Description','AllowPrivateCalling','AllowWebPSTNCalling','AllowVoicemail'
        'AllowCallGroups','AllowDelegation','AllowCallForwardingToUser','AllowCallForwardingToPhone','PreventTollBypass','BusyOnBusyEnabledType',
        'MusicOnHoldEnabledType','SafeTransferEnabled','AllowCloudRecordingForCalls','AllowTranscriptionForCalling',
        'LiveCaptionsEnabledTypeForCalling','AutoAnswerEnabledType','SpamFilteringEnabledType')
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}      
    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
        $cmdArgs.Add('Identity',$Identity)
    }    
    $result = Get-CsTeamsCallingPolicy @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $result    
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
    DisconnectS4B
}