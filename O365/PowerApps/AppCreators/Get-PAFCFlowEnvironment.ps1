#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    Returns information about one or more Flow environments that the user has access to

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
    Finds a specific environment

.Parameter Filter
    Finds environments matching the specified filter (wildcards supported)

.Parameter Default
    Finds the default environment

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [string]$EnvironmentName,
    [string]$Filter,
    [string]$ApiVersion,
    [ValidateSet('*','DisplayName','EnvironmentName','IsDefault','CreatedTime','CreatedBy','LastModifiedTime','LastModifiedBy','Location','Internal')]
    [string[]]$Properties = @('DisplayName','EnvironmentName','IsDefault','LastModifiedTime','LastModifiedBy')
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
        
    if($PSBoundParameters.ContainsKey('Filter')){
        $getArgs.Add('Filter',$Filter)
        if($PSBoundParameters.ContainsKey('ApiVersion')){
            $getArgs.Add('ApiVersion',$ApiVersion)
        }
    }
    elseif($PSBoundParameters.ContainsKey('EnvironmentName')){
        $getArgs.Add('EnvironmentName',$EnvironmentName)
        if($PSBoundParameters.ContainsKey('ApiVersion')){
            $getArgs.Add('ApiVersion',$ApiVersion)
        }
    }
    else{
        $getArgs.Add('Default',$Default)
    }    

    $result = Get-FlowEnvironment @getArgs | Select-Object $Properties
    
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