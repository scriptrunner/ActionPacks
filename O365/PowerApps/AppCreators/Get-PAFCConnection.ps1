#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    Returns connections for the calling user

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

.Parameter ConnectionName
    A connection identifier

.Parameter EnvironmentName
    Limit connections returned to those in a specified environment

.Parameter ConnectorNameFilter
    Finds connections created against a specific connector (wildcards supported)

.Parameter ReturnFlowConnections
     Every flow that is created also has an associated connection created with it

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [string]$ConnectionName,
    [switch]$ReturnFlowConnections,
    [string]$EnvironmentName,
    [string]$ConnectorNameFilter,
    [string]$ApiVersion,    
    [ValidateSet('*','DisplayName','ConnectionName','ConnectorName','EnvironmentName','CreatedTime','CreatedBy','LastModifiedTime','FullConnectorName','ConnectionId','Statuses','Internal')]
    [string[]]$Properties  = @('DisplayName','ConnectionName','ConnectorName','EnvironmentName','LastModifiedTime','ConnectionId')
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSBoundParameters.ContainsKey('ConnectorNameFilter')){
        $getArgs.Add('ConnectorNameFilter',$ConnectorNameFilter)
    }   
    if($PSBoundParameters.ContainsKey('ConnectionName')){
        $getArgs.Add('ConnectionName',$ConnectionName)
    }     
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('EnvironmentName')){
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    if($PSBoundParameters.ContainsKey('ReturnFlowConnections')){
        $getArgs.Add('ReturnFlowConnections',$ReturnFlowConnections)
    }

    $result = Get-PowerAppConnection @getArgs | Select-Object $Properties
    
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