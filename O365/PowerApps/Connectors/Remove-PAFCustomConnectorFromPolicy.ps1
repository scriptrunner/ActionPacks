#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Deletes a custom connector from the given DLP policy

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

.Parameter ConnectorName
    The Custom Connector's name

.Parameter PolicyName
    The PolicyName's identifier

.Parameter EnvironmentName
    The Environment's identifier

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
    [string]$ConnectorName,
    [string]$EnvironmentName,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'PolicyName' = $PolicyName
                            'ConnectorName' = $ConnectorName
                            }  
                            
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $cmdArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('EnvironmentName')){
        $cmdArgs.Add('EnvironmentName',$EnvironmentName)
    }

    $result = Remove-CustomConnectorFromPolicy @cmdArgs | Select-Object *
    
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