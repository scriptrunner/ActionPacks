#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Sets permissions to the connection

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Connections
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter ConnectionName
     The connection identifier

.Parameter EnvironmentName
    The connections's environment

.Parameter PrincipalObjectId
    The objectId of a user or group, if specified, this function will only return role assignments for that user or group

.Parameter ConnectorName
    The connection's connector identifier

.Parameter ApiVersion
    The api version to call with
    
.Parameter RoleName
    Specifies the permission level given to the connection

.Parameter PrincipalType
    Specifies the type of principal this connection is being shared with; a user, a security group, the entire tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]  
    [string]$ConnectionName,
    [Parameter(Mandatory = $true)]  
    [string]$ConnectorName,
    [Parameter(Mandatory = $true)]  
    [string]$EnvironmentName,
    [Parameter(Mandatory = $true)]  
    [string]$PrincipalObjectId,
    [Parameter(Mandatory = $true)]  
    [ValidateSet('CanView','CanViewWithShare','CanEdit')]
    [string]$RoleName,    
    [Parameter(Mandatory = $true)]  
    [ValidateSet('User','Group','Tenant')]
    [string]$PrincipalType,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential
    [string[]]$Properties = @('PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','ConnectionName','ConnectorName','EnvironmentName')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ConnectionName' = $ConnectionName
                            'ConnectorName' = $ConnectorName
                            'EnvironmentName' = $EnvironmentName
                            'RoleName' = $RoleName
                            'PrincipalType' = $PrincipalType
                            'PrincipalObjectId' = $PrincipalObjectId
                            }  
    
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $cmdArgs.Add('ApiVersion',$ApiVersion)
    }

    $result = Set-AdminPowerAppConnectionRoleAssignment @cmdArgs | Select-Object $Properties
    
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