#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Generates a report with all supported CDS database languages

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module Microsoft.PowerApps.Administration.PowerShell
    Requires Library script PAFLibrary.ps1
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/_REPORTS_
 
.Parameter PACredential
    [sr-en] Provides the user ID and password for PowerApps credentials
    [sr-de] Benutzername und Passwort für die Anmeldung

.Parameter LocationName
    [sr-en] The location of the current environment
    [sr-de] Standort der aktuellen Umgebung

.Parameter Filter
    [sr-en] Finds languages matching the specified filter (wildcards supported)
    [sr-de] Sprachen Filter (wildcards werden unterstützt)

.Parameter ApiVersion
    [sr-en] The api version to call with
    [sr-de] Verwendete API Version
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]   
    [string]$LocationName,
    [string]$Filter,
    [string]$ApiVersion    
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    [string[]]$Properties = @('LanguageName','LanguageDisplayName','IsTenantDefaultLanguag','LanguageLocalizedDisplayName')
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'LocationName' = $LocationName
                            }  
                            
    if([System.String]::IsNullOrWhiteSpace($Filter) -eq $false){
        $getArgs.Add('Filter',$Filter)
    }
    if([System.String]::IsNullOrWhiteSpace($ApiVersion) -eq $false){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }

    $result = Get-AdminPowerAppCdsDatabaseLanguages @getArgs | Select-Object $Properties
    
    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $result    
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
    DisconnectPowerApps
}