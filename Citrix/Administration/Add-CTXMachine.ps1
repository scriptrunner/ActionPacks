#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds a machine to a desktop group
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter MachineName
        [sr-en] Name of the machine to add (in the form 'domain\machine')
        [sr-de] Name der Maschine (Domäne\Maschinenname)

    .Parameter DesktopGroup
        [sr-en] Desktop group to which the machine are added, specified by name or Uid
        [sr-de] Desktop-Gruppe zu der die Maschine hinzugefügt wird, Name oder Uid
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MachineName,
    [Parameter(Mandatory = $true)]
    [string]$DesktopGroup,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('MachineName','PowerState','FaultState','MaintenanceModeReason','SessionCount','SessionState','CatalogName','DesktopGroupName','IPAddress','ZoneName','Uid','SessionsEstablished','SessionsPending')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    StartLogging -ServerAddress $SiteServer -LogText "Add machine $($MachineName) to desktop group $($DesktopGroup)" -LoggingID ([ref]$LogID)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MachineName' = $MachineName
                            'DesktopGroup' = $DesktopGroup
                            'LoggingID' = $LogID
                            }

    $ret = Add-BrokerMachine @cmdArgs | Select-Object $Properties
    $success = $true
    Write-Output $ret
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}