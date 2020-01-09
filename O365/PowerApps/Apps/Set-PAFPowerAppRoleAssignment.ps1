#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Set up permission to app depending on parameters

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
    App name for the one which you want to set permission

.Parameter EnvironmentName
     Limit app returned to those in a specified environment

.Parameter RoleName
    Specifies the permission level given to the app

.Parameter PrincipalType
    Specifies the type of principal this app is being shared with
    
.Parameter PrincipalObjectId
    If this app is being shared with a user or security group principal, this field specified the ObjectId for that principal

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]   
    [string]$AppName,
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
    [string[]]$Properties = @('PrincipalDisplayName','RoleName','RoleId','PrincipalEmail','AppName','EnvironmentName')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AppName' = $AppName
                            'EnvironmentName' = $EnvironmentName
                            'RoleName' = $RoleName
                            'PrincipalType' = $PrincipalType
                            'PrincipalObjectId' = $PrincipalObjectId
                            }  

    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $cmdArgs.Add('ApiVersion',$ApiVersion)
    }    

    $result = Set-AdminPowerAppRoleAssignment @cmdArgs | Select-Object $Properties
    
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