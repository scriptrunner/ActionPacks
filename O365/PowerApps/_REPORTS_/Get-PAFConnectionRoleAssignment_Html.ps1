#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Generates a report with the connection role assignments for a user or a connection. Owner role assignments cannot be deleted without deleting the connection resource

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

.Parameter ConnectionName
    [sr-en] The connection identifier
    [sr-de] ID der Connection

.Parameter EnvironmentName
    [sr-en] The connections's environment
    [sr-de] Name der Umgebung des Connectors 

.Parameter PrincipalObjectId
    [sr-en] The objectId of a user or group, if specified, this function will only return role assignments for that user or group
    [sr-de] Id eines Benutzers oder einer Gruppe, falls angegeben, gibt diese Funktion nur Rollenzuordnungen für diesen Benutzer oder diese Gruppe zurück

.Parameter ConnectorName
    [sr-en] The connection's connector identifier
    [sr-de] ID des Connectors 

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
    [string]$ConnectionName,
    [string]$ConnectorName,
    [string]$ApiVersion,
    [string]$EnvironmentName,
    [string]$PrincipalObjectId,
    [ValidateSet('*','PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','ConnectionName','ConnectorName','EnvironmentName','PrincipalObjectId','PrincipalType','RoleType','Internal')]
    [string[]]$Properties = @('PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','ConnectionName','ConnectorName','EnvironmentName')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'} 

    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('EnvironmentName')){
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    if($PSBoundParameters.ContainsKey('ConnectorName')){
        $getArgs.Add('ConnectorName',$ConnectorName)
    }    
    if($PSBoundParameters.ContainsKey('ConnectionName')){
        $getArgs.Add('ConnectionName',$ConnectionName)
    }
    if($PSBoundParameters.ContainsKey('PrincipalObjectId')){
        $getArgs.Add('PrincipalObjectId',$PrincipalObjectId)
    }

    $result = Get-AdminPowerAppConnectionRoleAssignment @getArgs | Select-Object $Properties
    
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