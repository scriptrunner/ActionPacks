#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Returns information about one or more PowerApps environments

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Environments
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter EnvironmentName
    Finds a specific environment
    
.Parameter Default
    Finds the default environment

.Parameter Filter
    Finds environments matching the specified filter (wildcards supported)

.Parameter Filtration
    Finds environments matching the specified filter (wildcards supported)

.Parameter CreatedBy
    Limit environments returned to only those created by the specified user 
    (you can specify a email address or object id)

.Parameter CreatedFrom
    Limit environments returned to only those created by the specified user 
    (you can specify a email address or object id)

.Parameter ApiVersion
    The api version to call with

.Parameter ReturnCdsDatabaseType
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [string]$EnvironmentName,
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]
    [string]$CreatedBy,
    [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
    [string]$Filter,
    [Parameter(ParameterSetName = 'User')]
    [string]$Filtration,
    [Parameter(ParameterSetName = 'Filter')]
    [string]$CreatedFrom,
    [Parameter(ParameterSetName = 'Default')]
    [switch]$Default ,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Name')]
    [string]$ApiVersion,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Name')]
    [bool]$ReturnCdsDatabaseType,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'Name')]
    [ValidateSet('*','DisplayName','EnvironmentType','EnvironmentName','Location','CreatedTime','CreatedBy','IsDefault','LastModifiedTime','LastModifiedBy','CreationType','CommonDataServiceDatabaseProvisioningState','CommonDataServiceDatabaseType')]
    [string[]]$Properties = @('DisplayName','EnvironmentType','EnvironmentName','Location','CreatedTime','CreatedBy')
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'Default'){
        $getArgs.Add('Default',$Default)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Name'){
        $getArgs.Add('EnvironmentName',$EnvironmentName)
        $getArgs.Add('ReturnCdsDatabaseType',$ReturnCdsDatabaseType)
        if($PSBoundParameters.ContainsKey('ApiVersion')){
            $getArgs.Add('ApiVersion',$ApiVersion)
        }
    }
    elseif($PSCmdlet.ParameterSetName -eq 'User'){
        $getArgs.Add('CreatedBy',$CreatedBy)
        if($PSBoundParameters.ContainsKey('Filtration')){
            $getArgs.Add('Filtration',$Filtration)
        }
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Filter'){
        $getArgs.Add('Filter',$Filter)
        $getArgs.Add('ReturnCdsDatabaseType',$ReturnCdsDatabaseType)
        if($PSBoundParameters.ContainsKey('CreatedFrom')){
            $getArgs.Add('CreatedFrom',$CreatedBy)
        }
        if($PSBoundParameters.ContainsKey('ApiVersion')){
            $getArgs.Add('ApiVersion',$ApiVersion)
        }
    }

    $result = Get-AdminPowerAppEnvironment @getArgs | Select-Object $Properties
    
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