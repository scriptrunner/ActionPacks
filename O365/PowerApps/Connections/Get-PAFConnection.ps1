#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Returns information about one or more connection

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

.Parameter ConnectorName
    Limit connections returned to those of a specified connector

.Parameter EnvironmentName
    Limit connections returned to those in a specified environment

.Parameter Filter
    Finds apps matching the specified filter (wildcards supported)

.Parameter UserName
    Limit connections returned to those created by by the specified user (email or AAD object id)

.Parameter CreatedBy
    Limit connections returned to those created by by the specified user (email or AAD object id)

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'Connector')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'Connector')]  
    [string]$ConnectorName,
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]
    [string]$UserName,
    [Parameter(ParameterSetName = 'Filter')]
    [string]$CreatedBy,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Connector')]
    [Parameter(ParameterSetName = 'User')]
    [string]$ApiVersion,    
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'Connector')]
    [string]$EnvironmentName,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'User')]
    [string]$Filter,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'Connector')]
    [ValidateSet('*','DisplayName','ConnectionName','ConnectorName','EnvironmentName','CreatedTime','CreatedBy','LastModifiedTime','FullConnectorName','ConnectionId','Statuses','Internal')]
    [string[]]$Properties  = @('DisplayName','ConnectionName','ConnectorName','EnvironmentName','LastModifiedTime','ConnectionId')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'Connector'){
        $getArgs.Add('ConnectorName',$ConnectorName)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'User'){
        $getArgs.Add('CreatedBy',$UserName)
    }   
    if($PSBoundParameters.ContainsKey('CreatedBy')){
        $getArgs.Add('CreatedBy',$CreatedBy)
    }     
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('EnvironmentName')){
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    if($PSBoundParameters.ContainsKey('Filter')){
        $getArgs.Add('Filter',$Filter)
    }

    $result = Get-AdminPowerAppConnection @getArgs | Select-Object $Properties
    
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