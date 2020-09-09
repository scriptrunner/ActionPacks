#Requires -Version 5.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Generates a report with information about users who have accounts homed on Skype for Business Online
    
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

    .Parameter User
        [sr-en] Indicates the Identity of the user account to be retrieved. User Identities can be specified using one of four formats: 
        1) the user's SIP address; 
        2) the user's user principal name (UPN); 
        3) the user's domain name and logon name, in the form domain\logon 
        4) the user's Active Directory display name 
        [sr-de] ID des Benutzers

    .Parameter ResultSize
        [sr-en] Enables you to limit the number of records returned
        [sr-de] Anzahl der Datensätze
    
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [string]$User,
    [int]$ResultSize = 50,
    [ValidateSet('*','Alias','DisplayName','Enabled','IsValid','SipAddress','PreferredLanguage','ObjectID','InterpretedUserType','UsageLocation','HideFromAddressLists','UserPrincipalName','FirstName','LastName')]
    [string[]]$Properties = @('DisplayName','Alias','Enabled','IsValid','SipAddress','PreferredLanguage')
)

Import-Module SkypeOnlineConnector

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    ConnectS4B -S4BCredential $SFBCredential

    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties = '*'
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ResultSize' = $ResultSize
                            }      
    if([System.String]::IsNullOrWhiteSpace($User) -eq $false){
        $cmdArgs.Add('Identity',$User)
    }    
    $result = Get-CsOnlineUser @cmdArgs | Sort-Object DisplayName | Select-Object $Properties

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