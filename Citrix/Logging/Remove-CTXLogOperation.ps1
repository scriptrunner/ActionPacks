#Requires -Version 5.0

<#
    .SYNOPSIS
        Deletes configuration logs
    
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

    .Parameter DatabaseCredentials	
        [sr-en] Credentials of a database user with permission to delete records from the Configuration Logging database
        [sr-de] Anmeldedaten eines Datenbankbenutzers mit der Berechtigung, Datensätze aus der Konfigurationsprotokoll-Datenbank zu löschen

    .Parameter StartDateRange	
        [sr-en] Start time of the earliest high level operation to delete
        [sr-de] Startzeit der frühesten zu löschenden High Level Operation
    
    .Parameter EndDateRange	
        [sr-en] End time of the latest high level operation to delete
        [sr-de] Endzeit der letzten zu löschenden High Level Operation

    .Parameter IncludeIncomplete	
        [sr-en] If incomplete high level operations should be deleted
        [sr-de] Unvollständige High Level Operationen löschen
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$DatabaseCredentials,
    [string]$ControllerServer,
    [datetime]$StartDateRange,
    [datetime]$EndDateRange,
    [switch]$IncludeIncomplete
)

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$ControllerServer)
    StartLogging -ServerAddress $ControllerServer -LogText "Remove configuration logs" -LoggingID ([ref]$LogID)
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $ControllerServer
                            'DatabaseCredentials' = $DatabaseCredentials
                            'LoggingId' = $LogID
                            }
    
    if($PSBoundParameters.ContainsKey('StartDateRange') -eq $true){
        $cmdArgs.Add('StartDateRange',$StartDateRange)
    }       
    if($PSBoundParameters.ContainsKey('EndDateRange') -eq $true){
        $cmdArgs.Add('EndDateRange',$EndDateRange)
    }
    if($IncludeIncomplete.IsPresent -eq $true){
        $cmdArgs.Add('IncludeIncomplete',$null)
    }   

    $ret = Remove-LogOperation @cmdArgs | Select-Object *
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
    StopLogging -LoggingID $LogID -ServerAddress $ControllerServer -IsSuccessful $success
    CloseCitrixSession
}