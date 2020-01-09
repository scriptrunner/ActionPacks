#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    Returns the app roles assignments for a user or an app

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module Microsoft.PowerApps.PowerShell
    Requires Library script PAFLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/AppCreators
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter EnvironmentName
    The app's environment

.Parameter PrincipalObjectId
    The objectId of a user or group, if specified, this function will only return role assignments for that user or group

.Parameter AppName
    The app identifier

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [string]$AppName,
    [string]$EnvironmentName,
    [string]$PrincipalObjectId,    
    [string]$ApiVersion,
    [ValidateSet('*','PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','ConnectorName','EnvironmentName','PrincipalObjectId','PrincipalType','RoleType','Internal')]
    [string[]]$Properties = @('PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','ConnectorName','EnvironmentName')
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential

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
    if($PSBoundParameters.ContainsKey('PrincipalObjectId')){
        $getArgs.Add('PrincipalObjectId',$PrincipalObjectId)
    }

    $result = Get-PowerAppConnectorRoleAssignment @getArgs | Select-Object $Properties
    
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
    DisconnectPowerApps4Creators
}