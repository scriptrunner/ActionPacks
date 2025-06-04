#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets one or more tags
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Name
        [sr-en] Tags that match the specified name
        [sr-de] Name des Tags

    .Parameter UUID
        [sr-en] Tags associated with a given UUID
        [sr-de] Tags mit dieser UUID

    .Parameter ApplicationUid
        [sr-en] Tags associated with the specified application
        [sr-de] Tags der Anwendung

    .Parameter ApplicationGroupUid
        [sr-en] Tags associated with the specified application group
        [sr-de] Tags der Anwendungsgruppe

    .Parameter DesktopUid
        [sr-en] Tags associated with the specified desktop
        [sr-de] Tags des Desktop

    .Parameter DesktopGroupUid
        [sr-en] Tags associated with the specified desktop group
        [sr-de] Tags des Desktop-Gruppe

    .Parameter MachineUid
        [sr-en] Tags associated with the specified machine
        [sr-de] Tags der Maschine

    .Parameter Description
        [sr-en] Tags with the specified description
        [sr-de] Tags mit dieser Beschreibung

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse
#>

param(
    [string]$Name,
    [string]$UUID,
    [string]$ApplicationUid,
    [string]$ApplicationGroupUid,
    [string]$DesktopUid,
    [string]$DesktopGroupUid,
    [string]$MachineUid,
    [string]$Description,
    [string]$SiteServer,
    [int]$MaxRecordCount = 250
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }    
    
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }
    if($PSBoundParameters.ContainsKey('UUID') -eq $true){
        $cmdArgs.Add('UUID',$UUID)
    }
    if($PSBoundParameters.ContainsKey('ApplicationUid') -eq $true){
        $cmdArgs.Add('ApplicationUid',$ApplicationUid)
    }
    if($PSBoundParameters.ContainsKey('ApplicationGroupUid') -eq $true){
        $cmdArgs.Add('ApplicationGroupUid',$ApplicationGroupUid)
    }
    if($PSBoundParameters.ContainsKey('DesktopUid') -eq $true){
        $cmdArgs.Add('DesktopUid',$DesktopUid)
    }
    if($PSBoundParameters.ContainsKey('DesktopGroupUid') -eq $true){
        $cmdArgs.Add('DesktopGroupUid',$DesktopGroupUid)
    }
    if($PSBoundParameters.ContainsKey('MachineUid') -eq $true){
        $cmdArgs.Add('MachineUid',$MachineUid)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    
    $ret = Get-BrokerTag @cmdArgs | Select-Object *
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}