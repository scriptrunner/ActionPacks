#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds machines from a catalog to a desktop group
    
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

    .Parameter Catalog
        [sr-en] Name or Uid of the machine catalog
        [sr-de] Name oder Uid des Maschinenkatalogs

    .Parameter Count
        [sr-en] Number of machines to add to the desktop group
        [sr-de] Anzahl der Maschinen die zur Bereitstellungsgruppe hinzufügt werden

    .Parameter DesktopGroup
        [sr-en] Desktop group to which the machines are added, specified by name or Uid
        [sr-de] Desktop-Gruppe zu der die Maschinen hinzugefügt werden, Name oder Uid
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Catalog,
    [Parameter(Mandatory = $true)]
    [int]$Count,
    [Parameter(Mandatory = $true)]
    [string]$DesktopGroup,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    StartLogging -ServerAddress $SiteServer -LogText "Add $($Count) machines to desktop group $($DesktopGroup)" -LoggingID ([ref]$LogID)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Catalog' = $Catalog
                            'DesktopGroup' = $DesktopGroup
                            'Count' = $Count
                            'LoggingID' = $LogID
                            }

    $ret = Add-BrokerMachinesToDesktopGroup @cmdArgs | Select-Object *
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