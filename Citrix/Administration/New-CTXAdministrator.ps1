#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds a new administrator to the site
    
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
        [sr-en] Name of the user or group in Active Directory
        [sr-de] Name des neuen Administrators

    .Parameter SID
        [sr-en] SID of the user in Active Directory
        [sr-de] SID des neuen Administrators

    .Parameter Enabled
        [sr-en] Administrator starts off enabled or not
        [sr-de] Administrator wird aktiviert
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$Name,    
    [Parameter(Mandatory = $true,ParameterSetName = 'BySID')]
    [string]$SID,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'BySID')]
    [string]$SiteServer,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'BySID')]
    [bool]$Enabled = $true
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Enabled','Rights','SID')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    [string]$tmpName = $Name
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Enabled' = $Enabled
                            }    

    if($PSCmdlet.ParameterSetName -eq 'BySID'){
        $cmdArgs.Add('Sid',$SID)
        $tmpName = $SID
    }
    else{
        $cmdArgs.Add('Name',$Name)
    }
    StartLogging -ServerAddress $SiteServer -LogText "New administrator $($tmpName)" -LoggingID ([ref]$LogID)
    $cmdArgs.Add('LoggingID',$LogID)
    
    $ret = New-AdminAdministrator @cmdArgs | Select-Object $Properties
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