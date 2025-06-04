#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the set of Right objects associated with the current user
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers
#>

param(
    [string]$SiteServer
    )                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            } 
    
    $ret = Get-AdminEffectiveRight @cmdArgs | Select-Object *
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}