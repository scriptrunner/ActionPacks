#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Sets permissions to the custom connectors

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

.Parameter ConnectorName
    The custom connector's identifier

.Parameter EnvironmentName
    The connectors's environment

.Parameter PrincipalType
    Specifies the type of principal this connector is being shared with

.Parameter PrincipalObjectId
    If this connector is being shared with a user or security group principal, this field specified the ObjectId for that principal

.Parameter ConnectorName
    The connector's identifier

.Parameter RoleName
    Specifies the permission level given to the connector

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]  
    [string]$ConnectorName,
    [Parameter(Mandatory = $true)]  
    [string]$EnvironmentName,
    [Parameter(Mandatory = $true)]  
    [ValidateSet('CanView', 'CanViewWithShare', 'CanEdit')]
    [string]$RoleName,
    [Parameter(Mandatory = $true)]  
    [ValidateSet('User', 'Group', 'Tenant')]
    [string]$PrincipalType,
    [Parameter(Mandatory = $true)]  
    [string]$PrincipalObjectId,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential
    [string[]]$Properties = @('PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','ConnectorName','EnvironmentName')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ConnectorName' = $ConnectorName
                            'EnvironmentName' = $EnvironmentName
                            'RoleName' = $RoleName
                            'PrincipalType' = $PrincipalType
                            'PrincipalObjectId' = $PrincipalObjectId
                            }  

    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $cmdArgs.Add('ApiVersion',$ApiVersion)
    }    

    $result = Set-AdminPowerAppConnectorRoleAssignment @cmdArgs | Select-Object $Properties
    
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