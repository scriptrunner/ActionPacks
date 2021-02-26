#Requires -Version 5.0

<#
    .SYNOPSIS
        Sets global configuration logging settings
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Logging
        
    .Parameter ControllerServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter State	
        [sr-en] Sets the state of configuration logging
        [sr-de] Status des Loggings

    .Parameter Locale	
        [sr-en] Sets the language that logs should be recorded in
        [sr-de] Legt die Log Sprache fest

    .Parameter LoggingDBPurgeDurationDays
        [sr-en] Sets the number of days for which the configuration logging logs will be retained
        [sr-de] Legt die Anzahl der Tage fest, für die die Konfigurationsprotokolle aufbewahrt werden
#>

param( 
    [string]$SiteServer,
    [ValidateSet('en','de','fr','es','ja','zh-CN')]
    [string]$Locale = 'en',
    [ValidateSet('Enabled','Disabled','Mandatory','NotSupported','unknown')]
    [bool]$State,
    [int]$LoggingDBPurgeDurationDays = 0
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Set log site" -LoggingID ([ref]$LogID)
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'PassThru' = $true
                            'Locale' = $Locale
                            'LoggingId' = $LogID
                            'LoggingDBPurgeDurationDays' = $LoggingDBPurgeDurationDays
                            }
    
    if($PSBoundParameters.ContainsKey('State') -eq $true){
        $cmdArgs.Add('State',$State)
    }

    $null = Set-LogSite @cmdArgs
    $ret = Get-LogSite -AdminAddress $SiteServer -ErrorAction Stop | Select-Object *
    $success = $true
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}