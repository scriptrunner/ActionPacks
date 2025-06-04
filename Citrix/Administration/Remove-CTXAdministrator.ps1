#Requires -Version 5.0

<#
    .SYNOPSIS
        Removes administrator from the site
    
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
        [sr-en] Name of the administrator to delete
        [sr-de] Name des zu löschenden Administrators

    .Parameter SID
        [sr-en] SID of the administrator to delete
        [sr-de] SID des zu löschenden Administrators
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$Name,    
    [Parameter(Mandatory = $true,ParameterSetName = 'BySID')]
    [string]$SID,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'BySID')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    [string]$tmpName = $Name
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }    

    if($PSCmdlet.ParameterSetName -eq 'BySID'){
        $cmdArgs.Add('Sid',$SID)
        $tmpName = $SID
    }
    else{
        $cmdArgs.Add('Name',$Name)
    }
    StartLogging -ServerAddress $SiteServer -LogText "Remove administrator $($tmpName)" -LoggingID ([ref]$LogID)
    $cmdArgs.Add('LoggingID',$LogID)
    
    $ret = Remove-AdminAdministrator @cmdArgs
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