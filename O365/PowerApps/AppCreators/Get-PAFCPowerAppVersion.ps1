#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    Returns all of versions of an app

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
    
.Parameter LatestDraft 
    Limits the query to only return the latest draft version of the app, if it exists

.Parameter LatestPublished
        Limits the query to only return the latest published version of the app
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]
    [string]$AppName,
    [switch]$LatestDraft,
    [switch]$LatestPublished,    
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.PowerShell

try{
    ConnectPowerApps4Creators -PAFCredential $PACredential

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'AppName' = $AppName
                            }  
                            
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }
    if($PSBoundParameters.ContainsKey('LatestDraft')){
        $getArgs.Add('LatestDraft',$LatestDraft)
    }
    if($PSBoundParameters.ContainsKey('LatestPublished')){
        $getArgs.Add('LatestPublished',$LatestPublished)
    }

    $result = Get-PowerAppVersion @getArgs | Select-Object *
    
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