#Requires -Version 5.0

<#
    .SYNOPSIS
        Create a new desktop group for managing the brokering of groups of desktops
    
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

    .Parameter Name
        [sr-en] Name of the new broker desktop group
        [sr-de] Name der neuen Desktop-Gruppe 

    .Parameter DesktopKind
        [sr-en] Kind of desktops this group will hold
        [sr-de] Typ der Desktops dieser Gruppe

    .Parameter PublishedName
        [sr-en] Name that will be displayed to users for their desktop(s) in this desktop group
        [sr-de] Name, der den Benutzern für ihre(n) Desktop(s) in dieser Desktop-Gruppe angezeigt wird

    .Parameter ColorDepth	
        [sr-en] Color depth of the desktop group
        [sr-de] Farbtiefe der Desktop-Gruppe

    .Parameter DeliveryType	
        [sr-en] Desktops, applications, or both, can be delivered from machines contained within the desktop group
        [sr-de] Bereitstellungsart von Desktops, Anwendungen oder beiden

    .Parameter Description 
        [sr-en] Description for this desktop group
        [sr-de] Beschreibung der Desktop Gruppe

    .Parameter Enabled	
        [sr-en] Enable or disable Desktop group. Disabled desktop groups do not appear to users
        [sr-de] Desktop-Gruppe aktivieren oder deaktivieren
        Deaktivierte Desktop-Gruppen werden den Benutzern nicht angezeigt

    .Parameter MinimumFunctionalLevel	
        [sr-en] Minimum FunctionalLevel required for machines to work successfully in the desktop group
        [sr-de] Mindest FunctionalLevel, damit Maschinen erfolgreich in der Desktop-Gruppe arbeiten können

    .Parameter InMaintenanceMode	
        [sr-en] Maintenance mode of the Desktop 
        Desktop group in maintenance mode will not allow users to connect or reconnect to their desktops
        [sr-de] Wartungsmodus des Desktops
        Eine Desktop-Gruppe im Wartungsmodus erlaubt es den Benutzern nicht, eine Verbindung zu ihren Desktops herzustellen oder wieder herzustellen

    .Parameter TenantId	
        [sr-en] Identity of tenant associated with desktop group
        [sr-de] Mandant der Desktop-Gruppe
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [Validateset('Shared','Private')]
    [string]$DesktopKind,
    [string]$SiteServer,
    [string]$PublishedName,
    [string]$Description,
    [ValidateSet('FourBit','EightBit','SixteenBit','TwentyFourBit')]
    [string]$ColorDepth,
    [Validateset('DesktopsOnly','AppsOnly','DesktopsAndApps')]
    [string]$DeliveryType,
    [Validateset('L5','L7','L7_6','L7_7','L7_8','L7_9','L7_20','L7_25')]
    [string]$MinimumFunctionalLevel = 'L7_6',
    [bool]$Enabled,
    [bool]$InMaintenanceMode,
    [string]$TenantId,    
    [Validateset('SingleSession','MultiSession')]
    [string]$SessionSupport
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','PublishedName','Description','Enabled','ColorDepth','DeliveryType','InMaintenanceMode','Uid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Create Desktop Group $($Name)" -LoggingID ([ref]$LogID)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'Name' = $Name
                            'DesktopKind' = $DesktopKind
                            'MinimumFunctionalLevel' = $MinimumFunctionalLevel
                            }
    
    if($PSBoundParameters.ContainsKey('PublishedName') -eq $true){
        $cmdArgs.Add('PublishedName',$PublishedName)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('ColorDepth') -eq $true){
        $cmdArgs.Add('ColorDepth',$ColorDepth)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('InMaintenanceMode') -eq $true){
        $cmdArgs.Add('InMaintenanceMode',$InMaintenanceMode)
    }
    if($PSBoundParameters.ContainsKey('DeliveryType') -eq $true){
        $cmdArgs.Add('DeliveryType',$DeliveryType)
    }
    if($PSBoundParameters.ContainsKey('TenantId') -eq $true){
        $cmdArgs.Add('TenantId',$TenantId)
    }
    if($PSBoundParameters.ContainsKey('SessionSupport') -eq $true){
        $cmdArgs.Add('SessionSupport',$SessionSupport)
    }

    $ret = New-BrokerDesktopGroup @cmdArgs | Select-Object $Properties
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