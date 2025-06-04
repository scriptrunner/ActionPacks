#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets Role Metadata
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter RoleName
        [sr-en] Name of the role
        [sr-de] Name der Rolle

    .Parameter RoleId
        [sr-en] Id of the role
        [sr-de] Identifier der Rolle
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$RoleName,
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$RoleId,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'ById')]
    [string]$SiteServer
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                        }

    if($PSCmdlet.ParameterSetName -eq 'ByName'){
        $cmdArgs.Add('Name',$RoleName)
    }   
    else{
        $cmdArgs.Add('Id',$RoleId)
    }  

    $ret = Get-AdminRole @cmdArgs | Select-Object -ExpandProperty MetadataMap
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}