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

    .Parameter OnModernServer
        [sr-en] Returns a collection of users homed on Skype for Business
        [sr-de] Sammlung von Nutzern, die Skype for Business nutzen

    .Parameter ResultSize
        [sr-en] Enables you to limit the number of records returned
        [sr-de] Anzahl der Datensätze

    .Parameter UnassignedUser
        [sr-en] Enables you to return a collection of all the users who have been enabled for Skype for Business but are not currently assigned to a Registrar pool
        [sr-de] Alle Nutzer, die für Skype for Business aktiviert wurden, aber derzeit keinem Registrar-Pool zugeordnet sind
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [switch]$OnModernServer,
    [int]$ResultSize,
    [switch]$UnassignedUser
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'OnModernServer' = $OnModernServer
                            'UnassignedUser' = $UnassignedUser
                            }  
    if($ResultSize -gt 0){
        $cmdArgs.Add('ResultSize',$ResultSize)
    }

    $result = Get-CsOnlineUser @cmdArgs | Select-Object *

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