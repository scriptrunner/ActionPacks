#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets Scope Metadata
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter ScopeName
        [sr-en] Name of the scope
        [sr-de] Name des Geltungsbereichs

    .Parameter ScopeId
        [sr-en] Id of the scope
        [sr-de] Identifier des Geltungsbereichs
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$ScopeName,
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$ScopeId,
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
        $cmdArgs.Add('Name',$ScopeName)
    }   
    else{
        $cmdArgs.Add('Id',$ScopeId)
    }  

    $ret = Get-AdminScope @cmdArgs | Select-Object -ExpandProperty MetadataMap
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}