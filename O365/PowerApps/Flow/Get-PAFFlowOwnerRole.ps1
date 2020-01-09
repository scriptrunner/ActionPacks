#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Gets owner permissions to the flow

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

.Parameter EnvironmentName
    The environment of the flow

.Parameter FlowName
    Specifies the flow id

.Parameter OwnerName
    A objectId of the user you want to filter by

.Parameter Owner
    A objectId of the user you want to filter by

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Flow')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'Environment')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'Flow')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Environment')]
    [string]$EnvironmentName,
    [Parameter(Mandatory = $true, ParameterSetName = 'Environment')]
    [string]$OwnerName,
    [Parameter(Mandatory = $true, ParameterSetName = 'Flow')]
    [string]$FlowName,
    [Parameter(ParameterSetName = 'Flow')]
    [string]$Owner,
    [Parameter(ParameterSetName = 'Flow')]
    [Parameter(ParameterSetName = 'Environment')]
    [string]$ApiVersion,
    [Parameter(ParameterSetName = 'Flow')]
    [Parameter(ParameterSetName = 'Environment')]
    [ValidateSet('*','RoleName','FlowName','EnvironmentName','RoleType','RoleId','PrincipalObjectId','PrincipalType','Internal')]
    [string[]]$Properties = @('RoleName','FlowName','EnvironmentName','RoleType','RoleId')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'Flow'){
        $getArgs.Add('FlowName',$FlowName)
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Environment'){
        $getArgs.Add('EnvironmentName',$EnvironmentName)
        $getArgs.Add('Owner',$OwnerName)
    }  

    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('Owner')){
        $getArgs.Add('Owner',$Owner)
    }

    $result = Get-AdminFlowOwnerRole @getArgs | Select-Object $Properties
    
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