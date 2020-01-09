#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Returns the connection role assignments for a user or a custom connection

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

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Connectors
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter EnvironmentName
    The connector's environment

.Parameter PrincipalObjectId
    The objectId of a user or group, if specified, this function will only return role assignments for that user or group

.Parameter ConnectorName
    The connector's identifier

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [string]$ConnectorName,
    [string]$ApiVersion,
    [string]$EnvironmentName,
    [string]$PrincipalObjectId,
    [ValidateSet('*','PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','ConnectorName','EnvironmentName','PrincipalObjectId','PrincipalType','RoleType','Internal')]
    [string[]]$Properties = @('PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','ConnectorName','EnvironmentName')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
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
    if($PSBoundParameters.ContainsKey('PrincipalObjectId')){
        $getArgs.Add('PrincipalObjectId',$PrincipalObjectId)
    }

    $result = Get-AdminPowerAppConnectorRoleAssignment @getArgs | Select-Object $Properties
    
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
    DisconnectPowerApps
}