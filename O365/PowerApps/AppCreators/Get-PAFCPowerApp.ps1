#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

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
    Requires Module Microsoft.PowerApps.PowerShell
    Requires Library script PAFLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/AppCreators
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter EnvironmentName
    Limit apps returned to those in a specified environment

.Parameter Filter
    Finds apps matching the specified filter (wildcards supported)

.Parameter MyEditable
    Limits the query to only apps that are owned or where the user has CanEdit access, 
    this filter is applicable only if the EnvironmentName parameter is populated

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
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [string]$AppName,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Name')]
    [string]$ApiVersion,    
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Name')]
    [string]$EnvironmentName,
    [Parameter(ParameterSetName = 'Filter')]
    [string]$Filter,    
    [Parameter(ParameterSetName = 'Filter')]
    [switch]$MyEditable,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Name')]
    [ValidateSet('*','DisplayName','AppName','EnvironmentName','CreatedTime','LastModifiedTime','UnpublishedAppDefinition','Internal')]
    [string[]]$Properties  = @('DisplayName','AppName','EnvironmentName','LastModifiedTime')
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'Name'){
        $getArgs.Add('AppName',$AppName)
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
    if($PSBoundParameters.ContainsKey('MyEditable')){
        $getArgs.Add('MyEditable',$null)
    }

    $result = Get-PowerApp @getArgs | Select-Object $Properties
    
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