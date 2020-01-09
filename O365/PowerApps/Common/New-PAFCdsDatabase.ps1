#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Creates a Common Data Service For Apps database for the specified environment

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

.Parameter CurrencyName
    The default currency for the database

.Parameter EnvironmentName
    The environment name

.Parameter LanguageName
    The default languages for the database

.Parameter WaitUntilFinished
    The function will not return a value until provisioning the database is complete (as either a success or failure)

.Parameter Templates
    The list of templates that used for provisision

.Parameter SecurityGroupId
    The Azure Active Directory security group object identifier to which to restrict database membership

.Parameter DomainName
    The domain name

.Parameter ApiVersion
    The api version to call with
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(Mandatory = $true)]   
    [string]$EnvironmentName,
    [Parameter(Mandatory = $true)]   
    [string]$CurrencyName,
    [Parameter(Mandatory = $true)]   
    [string]$LanguageName,    
    [bool]$WaitUntilFinished = $true,
    [string]$Templates,
    [string]$SecurityGroupId,
    [string]$DomainName,
    [string]$ApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    ConnectPowerApps -PAFCredential $PACredential
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'EnvironmentName' = $EnvironmentName
                            'CurrencyName' = $CurrencyName
                            'LanguageName' = $LanguageName
                            'WaitUntilFinished' = $WaitUntilFinished
                            }  
                            
    if($PSBoundParameters.ContainsKey('Templates')){
        $cmdArgs.Add('Templates',$Templates)
    }
    if($PSBoundParameters.ContainsKey('SecurityGroupId')){
        $cmdArgs.Add('SecurityGroupId',$SecurityGroupId)
    }
    if($PSBoundParameters.ContainsKey('DomainName')){
        $cmdArgs.Add('DomainName',$DomainName)
    }
    if($PSBoundParameters.ContainsKey('ApiVersion')){
        $cmdArgs.Add('ApiVersion',$ApiVersion)
    }

    $result = New-AdminPowerAppCdsDatabase @cmdArgs | Select-Object *
    
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