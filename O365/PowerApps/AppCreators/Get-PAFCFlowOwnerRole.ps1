#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    Gets owner permissions to the flow

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

.Parameter FlowName
    Specifies the flow id

.Parameter EnvironmentName
    The environment of the flow

.Parameter PrincipalObjectId
     Specifies the principal object Id of the user or security group

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [string]$FlowName,
    [string]$EnvironmentName,
    [string]$PrincipalObjectId,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential
    
    [hashtable]$setArgs = @{'ErrorAction' = 'Stop'}                                
    
    if($PSBoundParameters.ContainsKey('FlowName')){
        $setArgs.Add('FlowName',$FlowName)
    }
    if($PSBoundParameters.ContainsKey('EnvironmentName')){
        $setArgs.Add('EnvironmentName',$EnvironmentName)
    }
    if($PSBoundParameters.ContainsKey('PrincipalObjectId')){
        $setArgs.Add('PrincipalObjectId',$PrincipalObjectId)
    }
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $setArgs.Add('ApiVersion',$ApiVersion)
    }

    $result = Get-FlowOwnerRole @setArgs | Select-Object *
    
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