#Requires -Version 5.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Generates a report with information about your Auto Attendants (AA)
    
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

    .Parameter Descending
        [sr-en] The retrieved auto attendants would be sorted in descending order
        [sr-de] Auto Attendants in absteigender Reihenfolge

    .Parameter ExcludeContent
        [sr-en] Only auto attendants' names, identities and associated application instances will be retrieved
        [sr-de] Namen, Identitäten und zugehörigen Anwendungsinstanzen der Auto Attendants

    .Parameter IncludeStatus
        [sr-en] The status records for each auto attendant in the result set are also retrieved
        [sr-de] Anzeige der Statusaufzeichnungen für jeden Auto Attendant im Ergebnis

    .Parameter TenantID
        [sr-en] Unique identifier for the tenant
        [sr-de] Eindeutige ID des Mandanten
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [switch]$Descending,
    [switch]$ExcludeContent,
    [switch]$IncludeStatus,
    [string]$TenantID
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            "Descending"= $Descending
                            "ExcludeContent"= $ExcludeContent
                            "IncludeStatus" = $IncludeStatus
                        }

    if([System.String]::IsNullOrWhiteSpace($TenantID) -eq $false){
        $cmdArgs.Add('Tenant',$TenantID)
    }    

    $result = Get-CsAutoAttendant  @cmdArgs | Select-Object *

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