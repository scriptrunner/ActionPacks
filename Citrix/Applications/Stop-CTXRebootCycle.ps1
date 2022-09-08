#Requires -Version 5.0

<#
    .SYNOPSIS
        Cancels the specified reboot cycle
    
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
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter CatalogUid	
        [sr-en] Creates a reboot cycle for each desktop group that contains machines from this catalog
        [sr-de] Erzeugt einen Neustart-Zyklus für jede Desktop-Gruppe, die Rechner aus diesem Katalog enthält
#>
	  
param( 
    [Parameter(Mandatory = $true)]
    [string]$CatalogUid,
    [string]$SiteServer
) 

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    StartLogging -ServerAddress $SiteServer -LogText "Stop Reboot cycle" -LoggingID ([ref]$LogID)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            }

    $ret = Get-BrokerRebootCycle -CatalogUid $CatalogUid | Stop-BrokerRebootCycle @cmdArgs | Select-Object *
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