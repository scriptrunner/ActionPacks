#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets a list of sessions
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter SessionKey
        [sr-en] Session having the specified unique key
        [sr-de] Schlüssel Sitzung

    .Parameter UId
        [sr-en] Session by Uid
        [sr-de] UId der Sitzung

    .Parameter AppState
        [sr-en] Sessions by their app state
        [sr-de] App Status der Sitzungen 

    .Parameter AutonomouslyBrokered	
        [sr-en] Sessions according to whether they are autonomously brokered or not
        [sr-de] Eigenständige vermittelte Sitzungen

    .Parameter CatalogName	
        [sr-en] Sessions on machines from a specific catalog name
        [sr-de] Sitzungen dieses Maschinen-Katalog

    .Parameter ClientName
        [sr-en] Sessions by client name.
        [sr-de] Sitzungen dieses Client-Namens

    .Parameter ConnectionMode
        [sr-en] Sessions by the way in which the most recent connection to the session was established
        [sr-de] Sitzungen wie die letzte Verbindung zur Sitzung hergestellt wurde

    .Parameter DesktopGroupName
        [sr-en] Sessions from a desktop group with the specified name
        [sr-de] Sitzungen dieser Desktop-Gruppe

    .Parameter DesktopKind
        [sr-en] Sessions on a desktop of a particular kind
        [sr-de] Sitzungen dieses Desktop Typs

    .Parameter Hidden
        [sr-en] Sessions by whether they are hidden or not
        [sr-de] Unsichtbare Sitzungen

    .Parameter HostedMachineName	
        [sr-en] Sessions by their machine's name as known to its hypervisor
        [sr-de] Sitzungen des Hypervisor-Namen des Rechners

    .Parameter HostingServerName
        [sr-en] Sessions hosted by a machine with a specific name of the hosting hypervisor server
        [sr-de] Sitzungen, die von einem Rechner dieses Host-Hypervisor-Servers

    .Parameter InMaintenanceMode
        [sr-en] Sessions hosted by a machine with a specific ImageOutOfDate setting
        [sr-de] Sitzungen, auf Rechnern im Maintenance Modus

    .Parameter IsAnonymousUser
        [sr-en] Sessions hosted by a machine with a specific InMaintenanceMode setting
        [sr-de] Sitzungen, die anonym eingerichtet wurden

    .Parameter IsPhysical
        [sr-en] Sessions hosted on machines where the flag indicating if the machine can be power managed by the Citrix Broker Service matches the requested value
        [sr-de] Sitzungen, die auf Rechnern gehostet die vom Citrix Broker-Dienst mit Strom versorgt werden

    .Parameter LaunchedViaHostName	
        [sr-en] Sessions by the host name of the StoreFront server
        [sr-de] Sitzungen dieses StoreFront Servers

    .Parameter LogoffInProgress	
        [sr-en] Sessions by whether they are in the process of being logged off or not
        [sr-de] Sitzungen die gerade abgemeldet werden

    .Parameter LogonInProgress	
        [sr-en] Sessions by whether they are still executing user logon processing or not
        [sr-de] Sitzungen die gestartet werden

    .Parameter MachineName	
        [sr-en] Sessions by their machine name (in the form DOMAIN\machine)
        [sr-de] Sitzungen des Computers (Domäne\Computername)

    .Parameter MachineSummaryState
        [sr-en] Sessions on a machine with a specific summary state
        [sr-de] Sitzungen von Computern mit diesem Summary Status

    .Parameter PersistUserChanges	
        [sr-en] Sessions where the user changes are persisted in a particular manner
        [sr-de] Sitzungen mit diesem Typ von persistierten Änderungen des Benutzers

    .Parameter PowerState
        [sr-en] Sessions on machines in the specified power state
        [sr-de] Sitzungen auf Computern mit diesem Power Status 

    .Parameter ZoneName
        [sr-en] Sessions hosted on machines located in the zone with the specified name
        [sr-de] Sitzungen dieser Zone

    .Parameter Protocol
        [sr-en] Sessions by connection protocol
        [sr-de] Sitzungen mit diesem Verbindungsprotokoll

    .Parameter ProvisioningType
        [sr-en] Sessions hosted on machines provisioned in a particular manner
        [sr-de] Sitzungen die auf Rechnern mit diesem Bereitstellungs-Typ gehostet werden

    .Parameter SecureIcaActive
        [sr-en] Sessions by their use of SecureICA
        [sr-de] Sitzungen mit Secure ICA

    .Parameter SessionReconnection
        [sr-en] Sessions by their session reconnection (roaming) behavior
        [sr-de] Sitzungen mit diesem Sitzungswiederverbindungsverhalten (Roaming)

    .Parameter SessionState	
        [sr-en] Sessions by their state
        [sr-de] Sitzungen mit diesem Status

    .Parameter SessionSupport
        [sr-en] Sessions hosted on machines which support the required pattern of sessions
        [sr-de] Sitzungen von Rechnern, die diesen erforderliche Typ von Sitzungen unterstützen
        
    .Parameter SessionType
        [sr-en] Sessions by their type
        [sr-de] Sitzungen diese Typs        

    .Parameter UserName	
        [sr-en] Sessions by user name (in the form DOMAIN\user)
        [sr-de] Sitzung des Benutzers (dDomäne\Benutzername)

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'byId')]
    [Int64]$UId,
    [Parameter(ParameterSetName = 'Default')]
    [string]$SessionKey,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('PreLogon','PreLaunched','Active','Desktop','Lingering','NoApps')]
    [string]$AppState,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$AutonomouslyBrokered ,
    [Parameter(ParameterSetName = 'Default')]
    [string]$CatalogName,
    [Parameter(ParameterSetName = 'Default')]
    [string]$ClientName,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Brokered','Unbrokered','LeasedConnection','VdaHighAvailabilityMode','ThirdPartyBroker','ThirdPartyBrokerWithLicensing')]
    [string]$ConnectionMode,
    [Parameter(ParameterSetName = 'Default')]
    [string]$DesktopGroupName,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Private','Shared')]
    [string]$DesktopKind,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$Hidden ,
    [Parameter(ParameterSetName = 'Default')]
    [string]$HostedMachineName,
    [Parameter(ParameterSetName = 'Default')]
    [string]$HostingServerName,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$InMaintenanceMode ,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$IsAnonymousUser ,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$IsPhysical ,
    [Parameter(ParameterSetName = 'Default')]
    [string]$LaunchedViaHostName,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$LogoffInProgress ,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$LogonInProgress ,
    [Parameter(ParameterSetName = 'Default')]
    [string]$MachineName,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Off','Unregistered','Available','Disconnected','Preparing','InUse')]
    [string]$MachineSummaryState,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('OnLocal','Discard','OnPvd')]
    [string]$PersistUserChanges,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Unmanaged','Unknown','Unavailable','On','Suspended','TurningOn','TurningOff','Suspending','Resuming')]
    [string]$PowerState,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('HDX','RDP','Console')]
    [string]$Protocol,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Manual','PVS','MCS')]
    [string]$ProvisioningType,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$SecureIcaActive ,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Always','DisconnectedOnly','SameEndpointOnly')]
    [string]$SessionReconnection,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Other','PreparingNewSession','Connected','Active','Disconnected','Reconnecting','NonBrokeredSession','Unknown')]
    [string]$SessionState,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('SingleSession','MultiSession')]
    [string]$SessionSupport,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Application','Desktop')]
    [string]$SessionType,
    [Parameter(ParameterSetName = 'Default')]
    [string]$UserName,
    [Parameter(ParameterSetName = 'Default')]
    [string]$ZoneName,
    [Parameter(ParameterSetName = 'Default')]
    [int]$MaxRecordCount = 250,
    [Parameter(ParameterSetName = 'byId')]
    [Parameter(ParameterSetName = 'Default')]
    [string]$SiteServer,
    [Parameter(ParameterSetName = 'byId')]
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('*','AppState','ApplicationsInUse','CatalogName','ConnectedViaHostName','ConnectedViaIP','ConnectionMode','DesktopGroupName','EstablishmentTime','IsAnonymousUser','IsPhysical','LogoffInProgress','LogonInProgress','SessionState','SessionStateChangeTime','SessionSupport','SessionKey','SessionType','StartTime','Uid','UserName','ZoneName')]
    [string[]]$Properties = @('UserName','SessionState','Uid','SessionKey','ApplicationsInUse','StartTime','CatalogName','DesktopGroupName','ZoneName','EstablishmentTime')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'byId'){
        $cmdArgs.Add('Uid',$UId)
    }
    else{
        $cmdArgs.Add('MaxRecordCount',$MaxRecordCount)
        
        if($PSBoundParameters.ContainsKey('AutonomouslyBrokered') -eq $true){
            $cmdArgs.Add('AutonomouslyBrokered',$AutonomouslyBrokered)
        }
        if($PSBoundParameters.ContainsKey('Hidden') -eq $true){
            $cmdArgs.Add('Hidden',$Hidden)
        }
        if($PSBoundParameters.ContainsKey('InMaintenanceMode') -eq $true){
            $cmdArgs.Add('InMaintenanceMode',$InMaintenanceMode)
        }
        if($PSBoundParameters.ContainsKey('IsAnonymousUser') -eq $true){
            $cmdArgs.Add('IsAnonymousUser',$IsAnonymousUser)
        }
        if($PSBoundParameters.ContainsKey('IsPhysical') -eq $true){
            $cmdArgs.Add('IsPhysical',$IsPhysical)
        }
        if($PSBoundParameters.ContainsKey('LogoffInProgress') -eq $true){
            $cmdArgs.Add('LogoffInProgress',$LogoffInProgress)
        }
        if($PSBoundParameters.ContainsKey('LogonInProgress') -eq $true){
            $cmdArgs.Add('LogonInProgress',$LogonInProgress)
        }
        if($PSBoundParameters.ContainsKey('SecureIcaActive') -eq $true){
            $cmdArgs.Add('SecureIcaActive',$SecureIcaActive)
        }
        if($PSBoundParameters.ContainsKey('SessionKey') -eq $true){
            $cmdArgs.Add('SessionKey',$SessionKey)
        }
        if($PSBoundParameters.ContainsKey('AppState') -eq $true){
            $cmdArgs.Add('AppState',$AppState)
        }
        if($PSBoundParameters.ContainsKey('CatalogName') -eq $true){
            $cmdArgs.Add('CatalogName',$CatalogName)
        }
        if($PSBoundParameters.ContainsKey('ClientName') -eq $true){
            $cmdArgs.Add('ClientName',$ClientName)
        }
        if($PSBoundParameters.ContainsKey('ConnectionMode') -eq $true){
            $cmdArgs.Add('ConnectionMode',$ConnectionMode)
        }
        if($PSBoundParameters.ContainsKey('DesktopGroupName') -eq $true){
            $cmdArgs.Add('DesktopGroupName',$DesktopGroupName)
        }
        if($PSBoundParameters.ContainsKey('DesktopKind') -eq $true){
            $cmdArgs.Add('DesktopKind',$DesktopKind)
        }
        if($PSBoundParameters.ContainsKey('HostedMachineName') -eq $true){
            $cmdArgs.Add('HostedMachineName',$HostedMachineName)
        }
        if($PSBoundParameters.ContainsKey('HostedServerName') -eq $true){
            $cmdArgs.Add('HostedServerName',$HostedServerName)
        }
        if($PSBoundParameters.ContainsKey('LaunchedViaHostName') -eq $true){
            $cmdArgs.Add('LaunchedViaHostName',$LaunchedViaHostName)
        }
        if($PSBoundParameters.ContainsKey('MachineName') -eq $true){
            $cmdArgs.Add('MachineName',$MachineName)
        }
        if($PSBoundParameters.ContainsKey('MachineSummaryState') -eq $true){
            $cmdArgs.Add('MachineSummaryState',$MachineSummaryState)
        }
        if($PSBoundParameters.ContainsKey('PersistUserChanges') -eq $true){
            $cmdArgs.Add('PersistUserChanges',$PersistUserChanges)
        }
        if($PSBoundParameters.ContainsKey('PowerState') -eq $true){
            $cmdArgs.Add('PowerState',$PowerState)
        }
        if($PSBoundParameters.ContainsKey('Protocol') -eq $true){
            $cmdArgs.Add('Protocol',$Protocol)
        }
        if($PSBoundParameters.ContainsKey('ProvisioningType') -eq $true){
            $cmdArgs.Add('ProvisioningType',$ProvisioningType)
        }
        if($PSBoundParameters.ContainsKey('SessionReconnection') -eq $true){
            $cmdArgs.Add('SessionReconnection',$SessionReconnection)
        }
        if($PSBoundParameters.ContainsKey('SessionState') -eq $true){
            $cmdArgs.Add('SessionState',$SessionState)
        }
        if($PSBoundParameters.ContainsKey('SessionSupport') -eq $true){
            $cmdArgs.Add('SessionSupport',$SessionSupport)
        }
        if($PSBoundParameters.ContainsKey('SessionType') -eq $true){
            $cmdArgs.Add('SessionType',$SessionType)
        }
        if($PSBoundParameters.ContainsKey('ZoneName') -eq $true){
            $cmdArgs.Add('ZoneName',$ZoneName)
        }
        if($PSBoundParameters.ContainsKey('UserName') -eq $true){
            $cmdArgs.Add('UserName',$UserName)
        }
    }

    $ret = Get-BrokerSession @cmdArgs | Select-Object $Properties
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}