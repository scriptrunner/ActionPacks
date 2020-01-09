#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Removes the consent bypass so users are required to authorize API connections for the input PowerApp

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Apps
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter AppName
    App Id of PowerApp to operate on

.Parameter ForceLease
    Forces the lease when overwriting the PowerApp fields

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [string]$AppName,
    [Parameter(ParameterSetName = 'Filter')]
    [bool]$ForceLease,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'Filter')]
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential

    [hashtable]$setArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'Name'){
        $setArgs.Add('AppName',$AppName)
    }
     
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $setArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('ForceLease')){
        $setArgs.Add('ForceLease',$ForceLease)
    }

    $result = Clear-AdminPowerAppAsHero @setArgs | Select-Object *
    
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