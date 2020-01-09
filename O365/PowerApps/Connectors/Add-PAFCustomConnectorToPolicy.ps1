#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Adds a custom connector to the given group

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Connectors
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter PolicyName
    The PolicyName's identifier

.Parameter ConnectorId
    The Custom Connector's ID

.Parameter ConnectorName
    The Custom Connector's name

.Parameter ConnectorType
    The Custom Connector's type

.Parameter EnvironmentName
    The Environment's identifier

.Parameter GroupName 
    The name of the group to add the connector to

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]
    [string]$PolicyName,
    [Parameter(Mandatory = $true)]
    [string]$ConnectorId,
    [Parameter(Mandatory = $true)]
    [string]$ConnectorName,
    [Parameter(Mandatory = $true)]
    [string]$ConnectorType,
    [Parameter(Mandatory = $true)]
    [ValidateSet('hbi','lbi')]
    [string]$GroupName,
    [string]$EnvironmentName,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'PolicyName' = $PolicyName
                            'ConnectorId' = $ConnectorId
                            'ConnectorName' = $ConnectorName
                            'ConnectorType' = $ConnectorType
                            'GroupName' = $GroupName
                            }  

    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $cmdArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('EnvironmentName')){
        $cmdArgs.Add('EnvironmentName',$EnvironmentName)
    }

    $result = Add-CustomConnectorToPolicy @cmdArgs | Select-Object *
    
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