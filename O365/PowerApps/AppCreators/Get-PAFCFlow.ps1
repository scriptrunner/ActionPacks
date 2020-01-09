#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

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
    Requires Module Microsoft.PowerApps.PowerShell
    Requires Library script PAFLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/AppCreators
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter EnvironmentName
    Limit flows returned to those in a specified environment

.Parameter Filter
    Finds flows matching the specified filter (wildcards supported)

.Parameter FlowName
    Finds a specific id

.Parameter My
    Limits the query to only flows owned ONLY by the currently authenticated user

.Parameter Team
    Limits the query to flows owned by the currently authenticated user but shared with other users

.Parameter Top 
    Limits the result size of the query

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'Flow')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'Flow')]
    [string]$FlowName,
    [Parameter(ParameterSetName = 'Filter')]
    [string]$Filter,
    [Parameter(ParameterSetName = 'Filter')]
    [switch]$My,
    [Parameter(ParameterSetName = 'Filter')]
    [switch]$Team,
    [Parameter(ParameterSetName = 'Filter')]
    [int]$Top = 50,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Flow')]
    [string]$EnvironmentName,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Flow')]
    [string]$ApiVersion,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Flow')]
    [ValidateSet('*','DisplayName','FlowName','Enabled','EnvironmentName','CreatedTime','LastModifiedTime','UserType','Internal')]
    [string[]]$Properties = @('DisplayName','FlowName','Enabled','EnvironmentName','LastModifiedTime')
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
        
    if($PSCmdlet.ParameterSetName -eq 'Filter'){
        $getArgs.Add('My',$My)
        $getArgs.Add('Team',$Team)
    }
    else{
        $getArgs.Add('FlowName',$FlowName)
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
    if($PSBoundParameters.ContainsKey('Top')){
        $getArgs.Add('Top',$Top)
    }

    $result = Get-Flow @getArgs | Select-Object $Properties
    
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