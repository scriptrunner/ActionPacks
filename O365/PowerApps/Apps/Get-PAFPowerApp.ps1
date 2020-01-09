#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Returns information about one or more apps

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module Microsoft.PowerApps.Administration.PowerShell
    Requires Library script PAFLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Apps
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter Environment
    Limit apps returned to those in a specified environment

.Parameter EnvironmentName
    Limit apps returned to those in a specified environment

.Parameter Filter
    Finds apps matching the specified filter (wildcards supported)

.Parameter Owner
    Limit apps returned to those owned by the specified user (you can specify a email address or object id)

.Parameter AppName
    Finds a specific id

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
    [Parameter(Mandatory = $true, ParameterSetName = 'App')]
    [string]$AppName,
    [Parameter(Mandatory = $true,ParameterSetName = 'App')]
    [string]$Environment,
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]
    [string]$Owner,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'App')]
    [Parameter(ParameterSetName = 'User')]
    [string]$ApiVersion,    
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'User')]
    [string]$EnvironmentName,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'User')]
    [string]$Filter,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'App')]
    [ValidateSet('*','DisplayName','AppName','EnvironmentName','CreatedTime','LastModifiedTime','IsFeaturedApp','IsHeroApp','BypassConsent','Owner','UnpublishedAppDefinition','Internal')]
    [string[]]$Properties  = @('DisplayName','AppName','EnvironmentName','LastModifiedTime','Owner')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'App'){
        $getArgs.Add('AppName',$AppName)
        $getArgs.Add('EnvironmentName',$Environment)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'User'){
        $getArgs.Add('Owner',$Owner)
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

    $result = Get-AdminPowerApp @getArgs | Select-Object $Properties
    
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