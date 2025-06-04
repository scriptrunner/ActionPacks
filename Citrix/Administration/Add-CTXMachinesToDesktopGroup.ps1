#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds machines from a catalog to a desktop group
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Catalog
        [sr-en] Name or Uid of the machine catalog
        [sr-de] Name oder Uid des Maschinenkatalogs

    .Parameter Count
        [sr-en] Number of machines to add to the desktop group
        [sr-de] Anzahl der Maschinen die zur Bereitstellungsgruppe hinzufügt werden

    .Parameter DesktopGroup
        [sr-en] Desktop group to which the machines are added, specified by name or Uid
        [sr-de] Desktop-Gruppe zu der die Maschinen hinzugefügt werden, Name oder Uid
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Catalog,
    [Parameter(Mandatory = $true)]
    [int]$Count,
    [Parameter(Mandatory = $true)]
    [string]$DesktopGroup,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    StartLogging -ServerAddress $SiteServer -LogText "Add $($Count) machines to desktop group $($DesktopGroup)" -LoggingID ([ref]$LogID)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Catalog' = $Catalog
                            'DesktopGroup' = $DesktopGroup
                            'Count' = $Count
                            'LoggingID' = $LogID
                            }

    $ret = Add-BrokerMachinesToDesktopGroup @cmdArgs | Select-Object *
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