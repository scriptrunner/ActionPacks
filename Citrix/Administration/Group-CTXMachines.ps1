#Requires -Version 5.0

<#
    .SYNOPSIS
        Groups and counts machines with the same value for a specified property
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires PSSnapIn Citrix*
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter MachineName
        [sr-en] Machines with a specific machine name (in the form domain\machine)
        [sr-de] Name der Maschinen (Domäne\Maschinenname)

    .Parameter UId
        [sr-en] Machine by Uid
        [sr-de] UId der Maschine

    .Parameter AllocationType
        [sr-en] Machines from catalogs with the specified allocation type
        [sr-de] Maschinen mit diesem Zuweisungstyp

    .Parameter ApplicationInUse
        [sr-en] Machines running a specified published application (identified by browser name)
        String comparisons are case-insensitive
        [sr-de] Machinen auf denen eine bestimmte veröffentlichte Anwendung läuft (identifiziert durch den Browsernamen)
        String-Vergleiche sind case-insensitive

    .Parameter AssignedClientName
        [sr-en] Machines that have been assigned to the specific client name
        [sr-de] Maschinen die dem Client-Namen zugewiesen wurden

    .Parameter AssignedIPAddress
        [sr-en] Machines that have been assigned to the specific IP address
        [sr-de] Maschinen die der IP-Adresse zugewiesen wurden

    .Parameter AssociatedUserName 
        [sr-en] Machines with an associated user identified by their user name (in the form 'domain\user')
        [sr-de] Maschinen mit einem zugehörigen Benutzer (in der Form 'domain\user')

    .Parameter BrowserName	
        [sr-en] Assigned machines backing desktop resources that have browser names matching the specified name
        [sr-de] Zugewiesene Rechner, die Desktop-Ressourcen unterstützen, deren Browsernamen mit dem angegebenen Namen übereinstimmen

    .Parameter CatalogName	
        [sr-en] Machines from the catalog with the specific name
        [sr-de] Maschinen dieses Maschinenkatalogs

    .Parameter ColorDepth
        [sr-en] Machines configured with a specific color depth
        [sr-de] Maschinen mit dieser Farbtiefe

    .Parameter DeliveryType
        [sr-en] Machines of a particular delivery type
        [sr-de] Maschinen eines bestimmten Bereitstellungstyps

    .Parameter Description
        [sr-en] Machines with a specific description
        [sr-de] Maschinen mit dieser Beschreibung

    .Parameter DesktopCondition
        [sr-en] Machines with an outstanding desktop condition
        [sr-de] Maschinen mit diesem Desktop-Zustand

    .Parameter DesktopGroupName
        [sr-en] Machines from a desktop group with the specified name
        [sr-de] Maschinen dieser Bereitstellungsgruppe

    .Parameter FaultState
        [sr-en] Machines currently in the specified fault state
        [sr-de] Maschinen, die sich aktuell im angegebenen Fehlerzustand befinden

    .Parameter HostingServerName
        [sr-en] Machines by the name of the hosting hypervisor server
        [sr-de] Maschinen des Host-Hypervisor-Servers

    .Parameter InMaintenanceMode
        [sr-en] Machines by whether they are in maintenance mode 
        [sr-de] Maschinen im Maintenance Modus

    .Parameter IPAddress
        [sr-en] Machines with a specific IP address
        [sr-de] Maschinen mit dieser IP Adresse

    .Parameter IsAssigned
        [sr-en] Machines according to whether they are assigned 
        [sr-de] Nur zugewiesene Maschinen

    .Parameter LastConnectionFailure
        [sr-en] Machines with a specific reason for the last recorded connection failure
        [sr-de] Maschinen mit diesem letzten aufgezeichneten Verbindungsfehler-Typs

    .Parameter LastDeregistrationReason
        [sr-en] Machines whose broker last recorded a specific deregistration reason
        [sr-de] Maschinen mit diesem Abmeldegrund

    .Parameter MachineInternalState	
        [sr-en] Machines with the specified internal state
        [sr-de] Maschinen mit diesem internen Status

    .Parameter PersistUserChanges
        [sr-en] Machines by the location where the user changes are persisted
        [sr-de] Maschinen nach dem Ort, an dem die Benutzeränderungen aufbewahrt werden

    .Parameter PowerActionPending
        [sr-en] Machines depending on whether a power action is pending
        [sr-de] Maschinen bei denen eine Power-Aktion ansteht

    .Parameter PowerState
        [sr-en] Machines with a specific power state
        [sr-de] Maschinen mit diesem Power-Status

    .Parameter ProvisioningType
        [sr-en] Machines that are in a catalog with a particular provisioning type
        [sr-de] Maschinen mit dieser Bereitstellungsart

    .Parameter PublishedApplication
        [sr-en] Machines with a specific application published to them (identified by its browser name)
        [sr-de] Maschinen, auf denen diese Anwendung veröffentlicht ist (identifiziert durch den Namen des Browsers)

    .Parameter PvdStage
        [sr-en] Machines at a specific personal vDisk stage
        [sr-de] Maschinen mit einer bestimmten Personal-vDisk Stufe

    .Parameter RegistrationState
        [sr-en] Machines in a specific registration state
        [sr-de] Maschinen in einem bestimmten Registrierungsstatus

    .Parameter ScheduledReboot
        [sr-en] Machines according to their current status with respect to any scheduled reboots
        [sr-de] Maschinen entsprechend ihrem aktuellen Status in Bezug auf eventuelle geplante Reboots

    .Parameter SecureIcaRequired
        [sr-en] Machines configured with a particular SecureIcaRequired setting
        [sr-de] Maschinen mit konfigurierter SecureIcaRequired-Einstellung

    .Parameter SessionAutonomouslyBrokered
        [sr-en] Machines according to whether their current session is autonomously brokered
        [sr-de] Maschinen mit selbstständig vermittelter Sitzung

    .Parameter SessionClientName
        [sr-en] Machines with a specific client name
        [sr-de] Maschinen mit diesem Client Namen

    .Parameter SessionCount	
        [sr-en] Machines according to the total number of both pending and established user sessions on the machine
        [sr-de] Maschinen mit dieser Gesamtzahl der ausstehenden und eingerichteten Benutzersitzungen

    .Parameter SessionHidden
        [sr-en] Machines depending on whether their sessions are hidden
        [sr-de] Maschinen mit verborgenen Sitzungen 

    .Parameter SessionProtocol
        [sr-en] Machines with connections using a specific protocol
        [sr-de] Maschinen mit diesem Verbindungsprotokoll

    .Parameter SessionSecureIcaActive
        [sr-en] Machines depending on whether the current session uses SecureICA
        [sr-de] Machinen deren aktuelle Sitzung SecureIca verwendet

    .Parameter SessionState
        [sr-en] Machines with a specific session state
        [sr-de] Maschinen mit diesem Sitzungsstatus

    .Parameter SessionSupport
        [sr-en] Machines that have the specified session capability
        [sr-de] Maschinen mit dieser Sitzungsfunktion

    .Parameter SessionType	
        [sr-en] Machines with a specific session type
        [sr-de] Maschinen mit diesem Sizungstyp

    .Parameter VMToolsState	
        [sr-en] Machines with a specific VM tools state
        [sr-de] Maschinen mit diesem VM Tools Status
 
    .Parameter WillShutdownAfterUse
        [sr-en] Machines depending on whether they shut down after use
        [sr-de]	Maschinen die sich nach Gebrauch abschalten

    .Parameter WindowsConnectionSetting
        [sr-en] Machines according to their current Windows connection setting (logon mode)
        [sr-de] Maschinen mit diesem aktuellen Logon Mode

    .Parameter ZoneName
        [sr-en] Machines located in the zone with the specified name
        [sr-de] Machinen dieser Zone
        
    .Parameter Property	
        [sr-en] Property by which matching machines are grouped	
        [sr-de] Eigenschaft, nach der passende Maschinen gruppiert werden
        
    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse
#>

param(    
    [Parameter(Mandatory = $true,ParameterSetName = 'byId')]
    [Parameter(Mandatory = $true,ParameterSetName = 'Default')]
    [ValidateSet('AllocationType','ApplicationInUse','AssignedClientName','AssignedIPAddress','AssociatedUserName','BrowserName','CatalogName',
                'ColorDepth','DeliveryType','Description','DesktopCondition','DesktopGroupName','FaultState','InMaintenanceMode','IPAddress',
                'IsAssigned','LastConnectionFailure','LastDeregistrationReason','MachineInternalState','PersistUserChanges','PowerActionPending',
                'PowerState','ProvisioningType','PublishedApplication','PvdStage','RegistrationState','ScheduledReboot','SecureIcaRequired',
                'SessionAutonomouslyBrokered','SessionClientName','SessionCount','SessionHidden','SessionProtocol','SessionSecureIcaActive',
                'SessionState','SessionSupport','SessionType','VMToolsState','WindowsConnectionSetting','WillShutdownAfterUse','WillShutdownAfterUseReason')]
    [Int64]$Property,
    [Parameter(Mandatory = $true,ParameterSetName = 'byId')]
    [Int64]$UId,
    [Parameter(ParameterSetName = 'Default')]
    [string]$MachineName,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Permanent','Random','Static')]
    [string]$AllocationType,
    [Parameter(ParameterSetName = 'Default')]
    [string]$ApplicationInUse,
    [Parameter(ParameterSetName = 'Default')]
    [string]$AssignedClientName,
    [Parameter(ParameterSetName = 'Default')]
    [string]$AssignedIPAddress,
    [Parameter(ParameterSetName = 'Default')]
    [string]$AssociatedUserName,
    [Parameter(ParameterSetName = 'Default')]
    [string]$BrowserName,
    [Parameter(ParameterSetName = 'Default')]
    [string]$CatalogName,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('FourBit','EightBit','SixteenBit','TwentyFourBit')]
    [string]$ColorDepth,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('AppsOnly','DesktopsOnly','DesktopsAndApps')]
    [string]$DeliveryType,
    [Parameter(ParameterSetName = 'Default')]
    [string]$Description,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('CPU','ICALatency','UPMLogonTime')]
    [string]$DesktopCondition,
    [Parameter(ParameterSetName = 'Default')]
    [string]$DesktopGroupName,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('FailedToStart','MaxCapacity','StuckOnBoot','Unregistered','None')]
    [string]$FaultState,
    [Parameter(ParameterSetName = 'Default')]
    [string]$HostingServerName,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$InMaintenanceMode,
    [Parameter(ParameterSetName = 'Default')]
    [string]$IPAddress,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$IsAssigned,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('None','SessionPreparation','RegistrationTimeout','ConnectionTimeout','Licensing','Ticketing','Other')]
    [string]$LastConnectionFailure,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('AgentShutdown','AgentSuspended','AgentRequested','AgentAddressResolutionFailed','AgentNotContactable','AgentWrongActiveDirectoryOU','AgentRejectedSettingsUpdate',
                'BrokerRegistrationLimitReached','ContactLost','DesktopRestart','DesktopRemoved','EmptyRegistrationRequest','FunctionalLevelTooLowForCatalog','FunctionalLevelTooLowForDesktopGroup',
                'IncompatibleVersion','InconsistentRegistrationCapabilities','InvalidRegistrationRequest','MissingRegistrationCapabilities','MissingAgentVersion','NotLicensedForFeature',
                'OSNotCompatibleWithDdc','PowerOff','RegistrationStateMismatch','SendSettingsFailure','SessionAuditFailure','SessionPrepareFailure','SettingsCreationFailure','SingleMultiSessionMismatch','UnsupportedCredentialSecurityVersion')]
    [string]$LastDeregistrationReason,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Available','FullCapacity','Pending','SoftRegistered','Unavailable','Unknown','Unregistered')]
    [string]$MachineInternalState,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('OnLocal','Discard','OnPvd')]
    [string]$PersistUserChanges,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$PowerActionPending,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Unmanaged','Unknown','Unavailable','Off','On','Suspended','TurningOn','TurningOff','Suspending','Resuming')]
    [string]$PowerState,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Manual','PVS','MCS')]
    [string]$ProvisioningType,
    [Parameter(ParameterSetName = 'Default')]
    [string]$PublishedApplication,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('None','Requested','Starting','Working','Failed')]
    [string]$PvdStage,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Unregistered','Initializing','Registered','AgentError')]
    [string]$RegistrationState,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('None','Pending','Draining','InProgress','Natural')]
    [string]$ScheduledReboot,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$SecureIcaRequired,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$SessionAutonomouslyBrokered,
    [Parameter(ParameterSetName = 'Default')]
    [string]$SessionClientName,
    [Parameter(ParameterSetName = 'Default')]
    [int]$SessionCount,
    [Parameter(ParameterSetName = 'Default')]    
    [bool]$SessionHidden,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('HDX','RDP','Console')]
    [string]$SessionProtocol,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$SessionSecureIcaActive,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Other','PreparingSession','Connected','Active','Disconnected','Reconnecting','NonBrokeredSession','Unknown')]
    [string]$SessionState,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('SingleSession','MultiSession')]
    [string]$SessionSupport,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('Application','Desktop')]
    [string]$SessionType,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('NotPresent','Unknown','NotStarted','Running')]
    [string]$VMToolsState,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('LogonEnabled','Draining','DrainingUntilRestart','LogonDisabled')]
    [string]$WindowsConnectionSetting,
    [Parameter(ParameterSetName = 'Default')]
    [bool]$WillShutdownAfterUse,
    [Parameter(ParameterSetName = 'Default')]
    [ValidateSet('None','ResetDiskImage','ScheduledNaturalReboot')]
    [string]$WillShutdownAfterUseReason,
    [Parameter(ParameterSetName = 'Default')]
    [int]$MaxRecordCount = 250,
    [Parameter(ParameterSetName = 'byId')]
    [Parameter(ParameterSetName = 'Default')]
    [string]$SiteServer
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Property' = $Property
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'byId'){
        $cmdArgs.Add('Uid',$UId)
    }
    else{
        $cmdArgs.Add('MaxRecordCount',$MaxRecordCount)
        
        if($PSBoundParameters.ContainsKey('MachineName') -eq $true){
            $cmdArgs.Add('MachineName',$MachineName)
        }
        if($PSBoundParameters.ContainsKey('AllocationType') -eq $true){
            $cmdArgs.Add('AllocationType',$AllocationType)
        }
        if($PSBoundParameters.ContainsKey('ApplicationInUse') -eq $true){
            $cmdArgs.Add('ApplicationInUse',$ApplicationInUse)
        }
        if($PSBoundParameters.ContainsKey('AssignedClientName') -eq $true){
            $cmdArgs.Add('AssignedClientName',$AssignedClientName)
        }
        if($PSBoundParameters.ContainsKey('AssignedIPAddress') -eq $true){
            $cmdArgs.Add('AssignedIPAddress',$AssignedIPAddress)
        }
        if($PSBoundParameters.ContainsKey('AssociatedUserName') -eq $true){
            $cmdArgs.Add('AssociatedUserName',$AssociatedUserName)
        }
        if($PSBoundParameters.ContainsKey('BrowserName') -eq $true){
            $cmdArgs.Add('BrowserName',$BrowserName)
        }
        if($PSBoundParameters.ContainsKey('CatalogName') -eq $true){
            $cmdArgs.Add('CatalogName',$CatalogName)
        }
        if($PSBoundParameters.ContainsKey('ColorDepth') -eq $true){
            $cmdArgs.Add('ColorDepth',$ColorDepth)
        }
        if($PSBoundParameters.ContainsKey('DeliveryType') -eq $true){
            $cmdArgs.Add('DeliveryType',$DeliveryType)
        }
        if($PSBoundParameters.ContainsKey('Description') -eq $true){
            $cmdArgs.Add('Description',$Description)
        }
        if($PSBoundParameters.ContainsKey('DesktopCondition') -eq $true){
            $cmdArgs.Add('DesktopCondition',$DesktopCondition)
        }
        if($PSBoundParameters.ContainsKey('DesktopGroupName') -eq $true){
            $cmdArgs.Add('DesktopGroupName',$DesktopGroupName)
        }
        if($PSBoundParameters.ContainsKey('FaultState') -eq $true){
            $cmdArgs.Add('FaultState',$FaultState)
        }
        if($PSBoundParameters.ContainsKey('HostingServerName') -eq $true){
            $cmdArgs.Add('HostingServerName',$HostingServerName)
        }
        if($PSBoundParameters.ContainsKey('InMaintenanceMode') -eq $true){
            $cmdArgs.Add('InMaintenanceMode',$InMaintenanceMode)
        }
        if($PSBoundParameters.ContainsKey('IPAddress') -eq $true){
            $cmdArgs.Add('IPAddress',$IPAddress)
        }
        if($PSBoundParameters.ContainsKey('IsAssigned') -eq $true){
            $cmdArgs.Add('IsAssigned',$IsAssigned)
        }
        if($PSBoundParameters.ContainsKey('LastConnectionFailure') -eq $true){
            $cmdArgs.Add('LastConnectionFailure',$LastConnectionFailure)
        }
        if($PSBoundParameters.ContainsKey('LastDeregistrationReason') -eq $true){
            $cmdArgs.Add('LastDeregistrationReason',$LastDeregistrationReason)
        }
        if($PSBoundParameters.ContainsKey('MachineInternalState') -eq $true){
            $cmdArgs.Add('MachineInternalState',$MachineInternalState)
        }
        if($PSBoundParameters.ContainsKey('PersistUserChanges') -eq $true){
            $cmdArgs.Add('PersistUserChanges',$PersistUserChanges)
        }
        if($PSBoundParameters.ContainsKey('PowerActionPending') -eq $true){
            $cmdArgs.Add('PowerActionPending',$PowerActionPending)
        }
        if($PSBoundParameters.ContainsKey('PowerState') -eq $true){
            $cmdArgs.Add('PowerState',$PowerState)
        }
        if($PSBoundParameters.ContainsKey('ProvisioningType') -eq $true){
            $cmdArgs.Add('ProvisioningType',$ProvisioningType)
        }
        if($PSBoundParameters.ContainsKey('PublishedApplication') -eq $true){
            $cmdArgs.Add('PublishedApplication',$PublishedApplication)
        }
        if($PSBoundParameters.ContainsKey('PvdStage') -eq $true){
            $cmdArgs.Add('PvdStage',$PvdStage)
        }
        if($PSBoundParameters.ContainsKey('RegistrationState') -eq $true){
            $cmdArgs.Add('RegistrationState',$RegistrationState)
        }
        if($PSBoundParameters.ContainsKey('ScheduledReboot') -eq $true){
            $cmdArgs.Add('ScheduledReboot',$ScheduledReboot)
        }
        if($PSBoundParameters.ContainsKey('SecureIcaRequired') -eq $true){
            $cmdArgs.Add('SecureIcaRequired',$SecureIcaRequired)
        }
        if($PSBoundParameters.ContainsKey('SessionAutonomouslyBrokered') -eq $true){
            $cmdArgs.Add('SessionAutonomouslyBrokered',$SessionAutonomouslyBrokered)
        }
        if($PSBoundParameters.ContainsKey('SessionClientName') -eq $true){
            $cmdArgs.Add('SessionClientName',$SessionClientName)
        }
        if($PSBoundParameters.ContainsKey('SessionCount') -eq $true){
            $cmdArgs.Add('SessionCount',$SessionCount)
        }
        if($PSBoundParameters.ContainsKey('SessionHidden') -eq $true){
            $cmdArgs.Add('SessionHidden',$SessionHidden)
        }
        if($PSBoundParameters.ContainsKey('SessionProtocol') -eq $true){
            $cmdArgs.Add('SessionProtocol',$SessionProtocol)
        }
        if($PSBoundParameters.ContainsKey('SessionSecureIcaActive') -eq $true){
            $cmdArgs.Add('SessionSecureIcaActive',$SessionSecureIcaActive)
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
        if($PSBoundParameters.ContainsKey('VMToolsState') -eq $true){
            $cmdArgs.Add('VMToolsState',$VMToolsState)
        }
        if($PSBoundParameters.ContainsKey('WillShutdownAfterUse') -eq $true){
            $cmdArgs.Add('WillShutdownAfterUse',$WillShutdownAfterUse)
        }
        if($PSBoundParameters.ContainsKey('WillShutdownAfterUseReason') -eq $true){
            $cmdArgs.Add('WillShutdownAfterUseReason',$WillShutdownAfterUseReason)
        }
        if($PSBoundParameters.ContainsKey('WindowsConnectionSetting') -eq $true){
            $cmdArgs.Add('WindowsConnectionSetting',$WindowsConnectionSetting)
        }        
        if($PSBoundParameters.ContainsKey('ZoneName') -eq $true){
            $cmdArgs.Add('ZoneName',$ZoneName)
        }
    }

    $ret = Group-BrokerMachine @cmdArgs | Select-Object *
    Write-Output $ret
}
catch{
    throw 
}
finally{
    CloseCitrixSession
}