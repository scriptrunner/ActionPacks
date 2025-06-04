#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets Machine Metadata
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Name
        [sr-en] Machine with the specific machine name (in the form domain\machine)
        [sr-de] Name der Maschine (Domäne\Maschinenname)

    .Parameter Uid
        [sr-en] Uid of the machine
        [sr-de] Uid der Maschine
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$UId,
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
        $cmdArgs.Add('Name',$Name)
    }   
    else{
        $cmdArgs.Add('UId',$UId)
    }  

    $ret = Get-BrokerMachine @cmdArgs | Select-Object -ExpandProperty MetadataMap
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}