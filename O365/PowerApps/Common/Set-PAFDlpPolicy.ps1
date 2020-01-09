#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Updates a policy's environment and default api group settings

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

.Parameter PolicyName
    Policy name that will be updated

.Parameter EnvironmentName
    The Environment's identifier

.Parameter DefaultGroup
    The default group setting, hbi or lbi

.Parameter FilterType
    Identifies which filter type the policy will have

.Parameter Environments
    Comma seperated string list used as input environments to either include or exclude, depending on the FilterType

.Parameter SetNonBusinessDataGroupState
    Set non business data group(lbi)

.Parameter SchemaVersion
    Specifies the schema version to use

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'TenantPolicy')]  
    [Parameter(Mandatory = $true, ParameterSetName = 'EnvironmentPolicy')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'TenantPolicy')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'EnvironmentPolicy')] 
    [string]$PolicyName,
    [Parameter(Mandatory = $true, ParameterSetName = 'EnvironmentPolicy')] 
    [string]$EnvironmentName,
    [Parameter(ParameterSetName = 'TenantPolicy')]   
    [Parameter(ParameterSetName = 'EnvironmentPolicy')]   
    [ValidateSet('hbi','lbi')]
    [string]$DefaultGroup,
    [Parameter(ParameterSetName = 'TenantPolicy')]   
    [ValidateSet('None','Include','Exclude')]
    [string]$FilterType,
    [Parameter(ParameterSetName = 'TenantPolicy')]   
    [string]$Environments,
    [Parameter(ParameterSetName = 'TenantPolicy')]   
    [Parameter(ParameterSetName = 'EnvironmentPolicy')]   
    [ValidateSet('2016-11-01-preview','2018-11-01')]
    [string]$SchemaVersion,
    [Parameter(ParameterSetName = 'TenantPolicy')] 
    [Parameter(ParameterSetName = 'EnvironmentPolicy')]     
    [ValidateSet('Block','Unblock')]
    [string]$SetNonBusinessDataGroupState,
    [Parameter(ParameterSetName = 'TenantPolicy')]   
    [Parameter(ParameterSetName = 'EnvironmentPolicy')]   
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential
    [string[]]$Properties = @('DisplayName','PolicyName','LastModifiedTime','LastModifiedBy')
    
    [hashtable]$setArgs = @{'ErrorAction' = 'Stop'
                            'PolicyName' = $PolicyName
                            }  
                            
    if($PSCmdlet.ParameterSetName -eq 'EnvironmentPolicy'){
        $setArgs.Add('EnvironmentName',$EnvironmentName)
    }

    if($PSBoundParameters.ContainsKey('DefaultGroup')){
        $setArgs.Add('DefaultGroup',$DefaultGroup)
    }
    if($PSBoundParameters.ContainsKey('FilterType')){
        $setArgs.Add('FilterType',$FilterType)
    }
    if($PSBoundParameters.ContainsKey('Environments')){
        $setArgs.Add('Environments',$Environments)
    }
    if($PSBoundParameters.ContainsKey('SetNonBusinessDataGroupState')){
        $setArgs.Add('SetNonBusinessDataGroupState',$SetNonBusinessDataGroupState)
    }
    if($PSBoundParameters.ContainsKey('SchemaVersion')){
        $setArgs.Add('SchemaVersion',$SchemaVersion)
    }
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $setArgs.Add('ApiVersion',$ApiVersion)
    }

    $null = Set-AdminDlpPolicy @setArgs 
    $result = Get-AdminDlpPolicy -PolicyName $PolicyName -ErrorAction Stop | Select-Object $Properties
    
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