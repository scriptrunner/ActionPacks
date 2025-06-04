#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a new user object
    
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
        [sr-en] Name of the user or group (DOMAIN\Name)
        [sr-de] Benutzer- oder Gruppen-Name (Domäne\Name)

    .Parameter SID
        [sr-en] SID of the user or group
        [sr-de] Benutzer oder Gruppen SID
    #>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'byId')]
    [string]$SID,
    [Parameter(ParameterSetName = 'byName')]
    [string]$Name,
    [Parameter(ParameterSetName = 'byId')]
    [Parameter(ParameterSetName = 'byName')]
    [string]$SiteServer
)                                                            

try{ 
    [string[]]$Properties = @('Name','FullName','HomeZoneName','UPN','SID')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'byId'){
        $cmdArgs.Add('SID',$SID)
    }
    else{
        $cmdArgs.Add('Name',$Name)
    }
    
    $ret = New-BrokerUser @cmdArgs | Select-Object $Properties
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}