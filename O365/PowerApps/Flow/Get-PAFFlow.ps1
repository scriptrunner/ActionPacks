#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Returns information about one or more flows

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
    Limit flows returned to those in a specified environment

.Parameter Filter
    Finds flows matching the specified filter (wildcards supported)

.Parameter FlowName
    Finds a specific id

.Parameter CreatedBy
    Limit flows returned to those created by the specified user (you must specify a user's object id)

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'App')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]
    [string]$CreatedBy,
    [Parameter(Mandatory = $true, ParameterSetName = 'App')]
    [string]$FlowName,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'App')]
    [Parameter(ParameterSetName = 'User')]
    [string]$ApiVersion,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'App')]
    [Parameter(ParameterSetName = 'User')]
    [string]$EnvironmentName,
    [Parameter(ParameterSetName = 'Filter')]
    [string]$Filter,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'App')]
    [ValidateSet('*','DisplayName','FlowName','Enabled','EnvironmentName','CreatedTime','CreatedBy','LastModifiedTime','UserType','Internal')]
    [string[]]$Properties = @('DisplayName','FlowName','Enabled','EnvironmentName','LastModifiedTime')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'App'){
        $getArgs.Add('FlowName',$FlowName)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'User'){
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

    $result = Get-AdminFlow @getArgs | Select-Object $Properties
    
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