#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Generates a report with the information about one or more custom connectors

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

.Parameter EnvironmentName
    [sr-en] The connections's environment
    [sr-de] Name der Umgebung des Connectors 

.Parameter Filter
    [sr-en] Specifies the filter (wildcards supported)
    [sr-de] Filter (wildcards werden unterstützt)

.Parameter CreatedBy    
    [sr-en] Created by the specified user (email or AAD Principal object id)
    [sr-de] Nur Connectoren dieses Benutzers (email oder AAD Principal object id)

.Parameter ApiVersion
    [sr-en] The api version to call with
    [sr-de] Verwendete API Version
    
.Parameter Properties
    [sr-en] List of properties to expand. Use * for all properties
    [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [string]$CreatedBy,
    [string]$ApiVersion,
    [string]$EnvironmentName,
    [string]$Filter,
    [ValidateSet('*','DisplayName','ConnectorName','ConnectorId','EnvironmentName','CreatedTime','CreatedBy','ApiDefinitions','LastModifiedTime','Internal')]
    [string[]]$Properties = @('DisplayName','ConnectorName','ConnectorId','EnvironmentName','LastModifiedTime')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}                             
    
    if($PSBoundParameters.ContainsKey('CreatedBy')){
        $getArgs.Add('CreatedBy',$CreatedBy)
    }   
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('EnvironmentName')){
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    if($PSBoundParameters.ContainsKey('Filter')){
        $getArgs.Add('Filter',$Filter)
    }

    $result = Get-AdminPowerAppConnector @getArgs | Select-Object $Properties
    
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