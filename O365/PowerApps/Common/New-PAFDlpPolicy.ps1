#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Creates and inserts a new api policy into the tenant

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Common
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter DisplayName
    Creates the policy with the input display name

.Parameter EnvironmentName
    The Environment's identifier

.Parameter BlockNonBusinessDataGroup
    Block non business data group

.Parameter SchemaVersion
    Specifies the schema version to use

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]   
    [string]$DisplayName,
    [string]$EnvironmentName,
    [bool]$BlockNonBusinessDataGroup,
    [ValidateSet('2016-10-01-preview','2018-11-01')]
    [string]$SchemaVersion,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential
    [string[]]$Properties = @('DisplayName','PolicyName','CreatedTime','CreatedBy')
    
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'DisplayName' = $DisplayName
                            'BlockNonBusinessDataGroup' = $BlockNonBusinessDataGroup
                            }  
                            
    if($PSBoundParameters.ContainsKey('EnvironmentName')){
        $getArgs.Add('EnvironmentName',$EnvironmentName)
    }
    if($PSBoundParameters.ContainsKey('SchemaVersion')){
        $getArgs.Add('SchemaVersion',$SchemaVersion)
    }
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $getArgs.Add('ApiVersion',$ApiVersion)
    }

    $result = New-AdminDlpPolicy @getArgs | Select-Object $Properties
    
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