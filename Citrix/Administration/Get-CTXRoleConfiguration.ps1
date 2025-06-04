#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets roles configured for this site
    
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
        [sr-en] Role configurations matching the specified name
        [sr-de] Name der Rollenkonfiguration
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens

    .Parameter Id
        [sr-en] Role configuration with the specified id
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
    [string]$Name,
    [string]$Id,
    [string]$SiteServer,
    [string]$Locale,
    [string]$Priority,
    [string]$Version,
    [int]$MaxRecordCount = 250
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }    
    
    if($PSBoundParameters.ContainsKey('Id') -eq $true){
        $cmdArgs.Add('Id',$Id)
    }
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }
    if($PSBoundParameters.ContainsKey('Locale') -eq $true){
        $cmdArgs.Add('Locale',$Locale)
    }
    if($PSBoundParameters.ContainsKey('Priority') -eq $true){
        $cmdArgs.Add('Priority',$Priority)
    }
    if($PSBoundParameters.ContainsKey('Version') -eq $true){
        $cmdArgs.Add('Version',$Version)
    }
    
    $ret = Get-AdminRoleConfiguration @cmdArgs | Select-Object *
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}