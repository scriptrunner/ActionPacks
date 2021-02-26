#Requires -Version 5.0

<#
    .SYNOPSIS
        Associate Remote PC desktop groups with the specified Remote PC catalog
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Applications
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Catalog
        [sr-en] Name des Remote PC catalog which the desktop groups are to be added to
        [sr-de] Name des Maschinen-Katalogs

    .Parameter GroupNames
        [sr-en] Remote PC desktop groups to add to a Remote PC catalog, comma separated
        [sr-de] Name der Desktopgruppen die dem Maschinen-Katalog zugeordnet werden, Komma getrennt

    .Parameter Priority
        [sr-en] Desktop group to catalog associations carry a priority number, where numerically lower values indicate a higher priority
        [sr-de] Desktop-Gruppen zum Katalogisieren von Assoziationen tragen eine Prioritätsnummer, wobei numerisch niedrigere Werte eine höhere Priorität anzeigen
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Catalog,
    [Parameter(Mandatory = $true)]
    [string]$GroupNames,
    [string]$SiteServer,
    [int]$Priority
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Add desktop groups to catalog $($Catalog)" -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Priority' = $Priority
                            'RemotePCCatalog' = $Catalog
                            'Name' = $GroupNames
                            'LoggingId' = $LogID
                            }   
    
    $null = Add-BrokerDesktopGroup @cmdArgs
    $success = $true
    $ret = Get-BrokerCatalog -Name $Catalog -AdminAddress $SiteServer -ErrorAction Stop  | Select-Object -ExpandProperty RemotePCDesktopGroupUids
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