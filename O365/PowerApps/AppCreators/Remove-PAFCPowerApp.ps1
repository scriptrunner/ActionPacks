#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    Deletes the app

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

.Parameter AppName
    The app identifier

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]
    [string]$AppName,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AppName' = $AppName
                            }                              
    
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $cmdArgs.Add('ApiVersion',$ApiVersion)
    }

    $result = Remove-PowerApp @cmdArgs | Select-Object *
    
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