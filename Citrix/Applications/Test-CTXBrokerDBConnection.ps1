#Requires -Version 5.0

<#
    .SYNOPSIS
        Tests whether a database is suitable for use by the Citrix Broker Service
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Applications
        
    .Parameter ControllerServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter ConnectionString
        [sr-en] Database connection string to be tested by the currently selected Citrix Broker Service instance
        [sr-de] Datenbankverbindungszeichenfolge, die getestet werden soll
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,
    [string]$ControllerServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$ControllerServer)
    StartLogging -ServerAddress $ControllerServer -LogText "Test Broker database connection" -LoggingID ([ref]$LogID)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $ControllerServer
                            'DBConnection' = $ConnectionString
                            'LoggingId' = $LogID
                            }

    $tmp = Test-BrokerDBConnection @cmdArgs | Select-Object *
    $ret = $tmp | Select-Object -ExpandProperty ExtraInfo
    $ret.Add('ServiceStatus',$tmp.ServiceStatus)
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