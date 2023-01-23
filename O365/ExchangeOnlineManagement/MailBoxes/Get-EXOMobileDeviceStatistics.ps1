#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Gets the list of mobile devices configured to synchronize with a specified user's mailbox
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Requires PS Module ExchangeOnlineManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/MailBoxes

    .Parameter Mailbox
        [sr-en] Filters the results by the user mailbox that's associated with the mobile device
        GUID, User ID or user principal name
        [sr-de] Filtert die Ergebnisse nach dem Benutzerpostfach, das dem mobilen Gerät zugeordnet ist
        GUID, User ID oder UPN

    .Parameter ActiveSync
        [sr-en] Filters the results by Exchange ActiveSync devices
        [sr-de] Filtert die Ergebnisse nach Exchange ActiveSync-Geräten

    .Parameter OWAforDevices
        [sr-en] Filters the results by devices where Outlook on the web for devices is enabled
        [sr-de] Filtert die Ergebnisse nach Geräten, bei denen Outlook im Internet für Geräte aktiviert ist

    .Parameter RestApi
        [sr-en] Filters the results by REST API devices
        [sr-de] Filtert die Ergebnisse nach REST-API-Geräten
    
    .Parameter UniversalOutlook
        [sr-en] Filters the results by Mail and Calendar devices
        [sr-de] Filtert die Ergebnisse nach e-Mail-und Kalender Geräten
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Mailbox,
    [switch]$ActiveSync,
    [switch]$OWAforDevices,  
    [switch]$RestApi,
    [switch]$UniversalOutlook
)

Import-Module ExchangeOnlineManagement

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Mailbox' = $Mailbox
                    'ActiveSync' = $ActiveSync
                    'OWAforDevices' = $OWAforDevices
                    'RestApi' = $RestApi
                    'UniversalOutlook' = $UniversalOutlook
    }

    $result = Get-EXOMobileDeviceStatistics @cmdArgs | Select-Object *
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