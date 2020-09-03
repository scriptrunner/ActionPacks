#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Generates a report with environment role assignments for environments with a Common Data Service For Apps database instance

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
    [sr-en] Limit roles returned to those in a specified environment
    [sr-de] Name der Umgebung der Rolle 

.Parameter UserId
    [sr-en] A objectId of the user you want to filter by
    [sr-de] ID des Benutzers

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
    [string]$ApiVersion,
    [string]$EnvironmentName,
    [string]$UserId,
    [ValidateSet('*','PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','EnvironmentName','PrincipalObjectId','PrincipalType','RoleType','EnvironmentObject','Internal')]
    [string[]]$Properties = @('PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','EnvironmentName')
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
    if($PSBoundParameters.ContainsKey('UserId')){
        $getArgs.Add('UserId',$PrincipalObjectId)
    }

    $result = Get-AdminPowerAppEnvironmentRoleAssignment @getArgs | Select-Object $Properties
    
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