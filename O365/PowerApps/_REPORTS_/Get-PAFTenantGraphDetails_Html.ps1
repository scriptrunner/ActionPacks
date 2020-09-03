#Requires -Version 5.0
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    Generates a report with the tenant graph details

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
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/_REPORTS_

.Parameter PACredential
    [sr-en] Provides the user ID and password for PowerApps credentials
    [sr-de] Benutzername und Passwort für die Anmeldung

.Parameter GraphApiVersion
    [sr-en] The api version to call with
    [sr-de] Verwendete API Version
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [string]$GraphApiVersion
)

Import-Module Microsoft.PowerApps.Administration.PowerShell

try{
    [string[]]$Properties = @('ObjectType','TenantId','Country','Language','DisplayName')
    ConnectPowerApps -PAFCredential $PACredential
    
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if($PSBoundParameters.ContainsKey('GraphApiVersion')){
        $getArgs.Add('GraphApiVersion',$GraphApiVersion)
    }

    $result = Get-TenantDetailsFromGraph @getArgs | Select-Object $Properties
    
    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $result    
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