#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Returns permission information about one or more apps

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Apps
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter AppName
    The connection identifier

.Parameter EnvironmentName
    The connections's environment

.Parameter UserId
    The objectId of a user or group, if specified, this function will only return role assignments for that user or group

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = 'App')]   
    [Parameter(Mandatory = $true,ParameterSetName = 'User')]   
    [Parameter(Mandatory = $true,ParameterSetName = 'Environment')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true,ParameterSetName = 'App')]   
    [string]$AppName,
    [Parameter(ParameterSetName = 'App')]
    [Parameter(ParameterSetName = 'User')]    
    [Parameter(ParameterSetName = 'Environment')]
    [string]$ApiVersion,
    [Parameter(Mandatory = $true,ParameterSetName = 'App')]   
    [Parameter(Mandatory = $true,ParameterSetName = 'Environment')]   
    [string]$EnvironmentName,
    [Parameter(Mandatory = $true,ParameterSetName = 'Environment')]   
    [Parameter(Mandatory = $true,ParameterSetName = 'User')]  
    [Parameter(ParameterSetName = 'App')]
    [string]$UserId,
    [ValidateSet('*','PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','AppName','EnvironmentName','PrincipalObjectId','PrincipalType','RoleType','Internal')]
    [string[]]$Properties = @('PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','AppName','EnvironmentName')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  

    if($PSCmdlet.ParameterSetName -eq 'App'){
        $getArgs.Add('AppName',$AppName)
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'User'){
        $getArgs.Add('UserId',$UserId)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Environment'){
        $getArgs.Add('UserId',$UserId)
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }    

    $result = Get-AdminPowerAppRoleAssignment @getArgs | Select-Object $Properties
    
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