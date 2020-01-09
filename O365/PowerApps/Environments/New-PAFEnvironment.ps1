#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Creates an Environment

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/Environments
 
.Parameter PACredential
    Provides the user ID and password for PowerApps credentials

.Parameter DisplayName
    The display name of the new Environment
    
.Parameter LocationName
    The location of the new Environment

.Parameter EnvironmentSku
    The Environment type

.Parameter CurrencyName
    The default currency for the database

.Parameter LanguageName
    The default languages for the database

.Parameter Templates
    The list of templates used for provisioning, comma separated

.Parameter SecurityGroupId
    The Azure Active Directory security group object identifier to restrict database membership

.Parameter DomainName 
    The domain name

.Parameter WaitUntilFinished
    The function will not return until provisioning the database is complete

.Parameter ProvisionDatabase
    Provision Cds database along with creating the environment. 
    If set, LanguageName and CurrencyName are mandatory to pass as arguments

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'ProvisionDatabase')]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [ValidateSet('Trial','Production')]
    [string]$EnvironmentSku,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [string]$LocationName,
    [Parameter(ParameterSetName = 'Name')]
    [string]$DisplayName,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'ProvisionDatabase')]
    [string]$DomainName,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'ProvisionDatabase')]
    [string]$LanguageName,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'ProvisionDatabase')]
    [string]$CurrencyName,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'ProvisionDatabase')]
    [string]$SecurityGroupId,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'ProvisionDatabase')]
    [string]$Templates,
    [Parameter(ParameterSetName = 'Name')]
    [Parameter(ParameterSetName = 'User')]
    [Parameter(ParameterSetName = 'ProvisionDatabase')]
    [bool]$WaitUntilFinished,
    [Parameter(ParameterSetName = 'User')]
    [string]$ApiVersion,
    [Parameter(ParameterSetName = 'ProvisionDatabase')]
    [switch]$ProvisionDatabase
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential
    [string[]]$Properties = @('DisplayName','EnvironmentType','EnvironmentName','Location','CreatedTime','CreatedBy')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSCmdlet.ParameterSetName -eq 'Name'){
        $cmdArgs.Add('EnvironmentSku',$EnvironmentSku)
        $cmdArgs.Add('LocationName',$LocationName)        
    }
    elseif($PSCmdlet.ParameterSetName -eq 'User'){
        if($PSBoundParameters.ContainsKey('ApiVersion')){
            $cmdArgs.Add('ApiVersion',$Filtration)
        }
    }
    elseif($PSCmdlet.ParameterSetName -eq 'ProvisionDatabase'){
        if($ProvisionDatabase -eq $true){
            $cmdArgs.Add('ProvisionDatabase',$ProvisionDatabase)
        }
    }    
    if($PSBoundParameters.ContainsKey('DisplayName')){
        $cmdArgs.Add('DisplayName',$DisplayName)
    }
    if($PSBoundParameters.ContainsKey('CurrencyName')){
        $cmdArgs.Add('CurrencyName',$CurrencyName)
    }
    if($PSBoundParameters.ContainsKey('LanguageName')){
        $cmdArgs.Add('LanguageName',$LanguageName)
    }
    if($PSBoundParameters.ContainsKey('DomainName')){
        $cmdArgs.Add('DomainName',$DomainName)
    }
    if($PSBoundParameters.ContainsKey('SecurityGroupId')){
        $cmdArgs.Add('SecurityGroupId',$SecurityGroupId)
    }
    if($PSBoundParameters.ContainsKey('Templates')){
        [string[]]$tmp = $Templates.Split(',')
        $cmdArgs.Add('Templates',$tmp)
    }
    if($PSBoundParameters.ContainsKey('WaitUntilFinished')){
        $cmdArgs.Add('WaitUntilFinished',$WaitUntilFinished)
    }

    $result = New-AdminPowerAppEnvironment @cmdArgs | Select-Object $Properties
    
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