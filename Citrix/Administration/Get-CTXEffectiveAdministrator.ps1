#Requires -Version 5.0

<#
    .SYNOPSIS
        Retrieve the effective administrator objects for a user
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter UserName
        [sr-en] User name or SID of user to query
        [sr-de] Benutzer Name oder SID
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserName,
    [string]$SiteServer
    )                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $UserName
                            } 
    
    $ret = Get-AdminEffectiveAdministrator @cmdArgs | Select-Object *
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}