#Requires -Version 5.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Generates a report with the telephone number inventory types that are defined
    
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
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Force' = $true
                            }  

    $result = Get-CsOnlineTelephoneNumberInventoryTypes @cmdArgs | Select-Object *

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