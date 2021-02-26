#Requires -Version 5.0

<#
    .SYNOPSIS
        Imports role configuration data into the Delegated Administration Service
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Administration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Path
        [sr-en] Path to the file containing the role configuration data
        [sr-de] Pfad und Name der Rollenkonfiguration

    .Parameter Id
        [sr-en] Role configurations with the specified id
        [sr-de] Identifier der Rollenkonfiguration

    .Parameter Locale
        [sr-en] Role configurations with the specified locale
        [sr-de] Rollenkonfiguration die entsprechend lokalisiert sind

    .Parameter Priority
        [sr-en] Role configurations with the specified priority
        [sr-de] Rollenkonfiguration die entsprechend priorisiert sind

    .Parameter Version
        [sr-en] Role configurations with the matching version number
        [sr-de] Rollenkonfiguration der entsprechenden Version

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$Id,
    [string]$SiteServer,
    [string]$Locale,
    [string]$Priority,
    [string]$Version,
    [int]$MaxRecordCount = 250
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Import role configuration" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Path' = $Path
                            'Force' = $null
                            'LoggingId' = $LogID
                            }    
    
    $ret = Import-AdminRoleConfiguration @cmdArgs | Select-Object *
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