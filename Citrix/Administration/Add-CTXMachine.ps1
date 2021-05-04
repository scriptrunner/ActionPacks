#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds a machine to a desktop group
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Administration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter MachineName
        [sr-en] Name of the machine to add (in the form 'domain\machine')
        [sr-de] Name der Maschine (Domäne\Maschinenname)

    .Parameter Uid
        [sr-en] Uid of the machine to add
        [sr-de] UId der Maschine

    .Parameter DesktopGroup
        [sr-en] Desktop group to which the machine are added, specified by name or Uid
        [sr-de] Desktop-Gruppe zu der die Maschine hinzugefügt wird, Name oder Uid
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MachineName,
    [Parameter(Mandatory = $true)]
    [string]$DesktopGroup,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('MachineName','PowerState','FaultState','MaintenanceModeReason','SessionCount','SessionState','CatalogName','DesktopGroupName','IPAddress','ZoneName','Uid','SessionsEstablished','SessionsPending')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    StartLogging -ServerAddress $SiteServer -LogText "Add machine $($MachineName) to desktop group $($DesktopGroup)" -LoggingID ([ref]$LogID)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MachineName' = $MachineName
                            'DesktopGroup' = $DesktopGroup
                            'LoggingID' = $LogID
                            }

    $ret = Add-BrokerMachine @cmdArgs | Select-Object $Properties
    $success = $true
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw 
}
finally{
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}