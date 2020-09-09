#Requires -Version 5.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Generates a report with the properties and settings of users that are enabled for dial-in conferencing and are using Microsoft or third-party provider as their PSTN conferencing provider
    
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

    .Parameter Select
        [sr-en] Filter the output
        [sr-de] Filter

    .Parameter Skip
        [sr-en] Skips (does not select) the specified number of items
        [sr-de] Überspringt (wählt nicht aus) die angegebene Anzahl von Elementen

    .Parameter SortDescending
        [sr-en] Indicates that the cmdlet sorts the objects in descending order
        [sr-de] Objekte in absteigender Reihenfolge sortieren

    .Parameter First
        [sr-en] Returns the first X number of users from the list of all the users enabled for dial-in conferencing
        [sr-de] Die ersten Benutzer aus der Liste aller Benutzer zurück, die für Einwahl-Konferenzen aktiviert sind

    .Parameter TenantID
        [sr-en] Unique identifier for the tenant
        [sr-de] Eindeutige ID des Mandanten
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [ValidateSet('DialInConferencingOn','DialInConferencingOff','ConferencingProviderMS','ConferencingProviderOther','ReadyForMigrationToCPC','NoFilter')]
    [string]$Select,
    [int]$Skip,
    [switch]$SortDescending,
    [int]$First,
    [string]$TenantID
)

Import-Module SkypeOnlineConnector

try{
    [string[]]$Properties = @('DisplayName','ObjectId','Provider','DefaultTollNumber','DefaultTollFreeNumbers','ConferenceId','Identity')

    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Force' = $true
                            'SortDescending' = $SortDescending
                            }      
    if([System.String]::IsNullOrWhiteSpace($Select) -eq $false){
        $cmdArgs.Add('Select',$Select)
    }   
    if([System.String]::IsNullOrWhiteSpace($TenantID) -eq $false){
        $cmdArgs.Add('Tenant',$TenantID)
    }   
    if($Skip -gt 0){
        $cmdArgs.Add('Skip',$Skip)
    }  
    if($First -gt 0){
        $cmdArgs.Add('First',$First)
    }    

    $result = Get-CsOnlineDialInConferencingUserInfo @cmdArgs | Select-Object $Properties

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