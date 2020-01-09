#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    Returns connectors for the calling user

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
    Limit connectors returned to those in a specified environment

.Parameter Environment
    Limit connectors returned to those in a specified environment

.Parameter Filter
    Finds connectors matching the specified filter (wildcards supported), searches against the Connector's Name and DisplayName

.Parameter ConnectorName
    Limits the details returned to only a certain specific connector

.Parameter FilterNonCustomConnectors
    Setting this flag will filter out all of the shared connectors built by microsfot such as Twitter, SharePoint, OneDrive, etc.

.Parameter ReturnConnectorSwagger
    This parameter can only be set if the ConnectorName is populated, and, when set, will return additional metdata for the connector such as the Swagger and runtime Urls

.Parameter ApiVersion
    The api version to call with
    
.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Connector')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'Connector')]
    [string]$ConnectorName,
    [Parameter(Mandatory = $true, ParameterSetName = 'Connector')]
    [string]$EnvironmentName,
    [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
    [string]$Filter,
    [Parameter(ParameterSetName = 'Filter')]   
    [switch]$FilterNonCustomConnectors,
    [Parameter(ParameterSetName = 'Connector')]   
    [switch]$ReturnConnectorSwagger,
    [Parameter(ParameterSetName = 'Filter')]
    [string]$Environment,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Connector')]
    [string]$ApiVersion,
    [Parameter(ParameterSetName = 'Filter')]
    [Parameter(ParameterSetName = 'Connector')]
    [ValidateSet('*','DisplayName','ConnectorName','ConnectorId','EnvironmentName','CreatedTime','Description','ApiDefinitions','Publisher','Source','Tier','Url','ChangedTime','ConnectionParameters','Swagger','WadlUrl','Internal')]
    [string[]]$Properties = @('DisplayName','Description','ConnectorName','ConnectorId','EnvironmentName','ChangedTime')
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'Connector'){
        $getArgs.Add('ConnectorName',$ConnectorName)
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    else{
        $getArgs.Add('Filter',$Filter)
        if($PSBoundParameters.ContainsKey('Environment')){
            $getArgs.Add('EnvironmentName',$Environment)
        }
    }   
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('FilterNonCustomConnectors')){
        $getArgs.Add('FilterNonCustomConnectors',$FilterNonCustomConnectors)
    }
    if($PSBoundParameters.ContainsKey('ReturnConnectorSwagger')){
        $getArgs.Add('ReturnConnectorSwagger',$ReturnConnectorSwagger)
    }

    $result = Get-PowerAppConnector @getArgs | Select-Object $Properties
    
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