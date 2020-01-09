#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Sets owner permissions to the flow

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Flow
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter FlowName
    Specifies the flow id

.Parameter EnvironmentName
    Limit app returned to those in a specified environment

.Parameter PrincipalObjectId
    Specifies the principal object Id of the user or security group

.Parameter PrincipalType
    Specifies the type of principal that is being added as an owner

.Parameter RoleName
    Specifies the access level for the user on the flow

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]
    [string]$FlowName,
    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('User','Group')]
    [string]$PrincipalType,
    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,
    [Parameter(Mandatory = $true)]
    [ValidateSet('CanView','CanEdit')]
    [string]$RoleName,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential
    
    [hashtable]$setArgs = @{'ErrorAction' = 'Stop'
                            'EnvironmentName' = $EnvironmentName
                            'FlowName' = $FlowName
                            'RoleName' = $RoleName
                            'PrincipalObjectId' = $PrincipalObjectId
                            'PrincipalType' = $PrincipalType
                            }                                
    
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $setArgs.Add('ApiVersion',$ApiVersion)
    }

    $result = Set-AdminFlowOwnerRole @setArgs | Select-Object *
    
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