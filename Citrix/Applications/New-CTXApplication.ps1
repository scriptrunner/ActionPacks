#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a new published application
    
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

    .Parameter ApplicationName
        [sr-en] Name of the application (must be unique within folder)
        [sr-de] Name der Anwendung (eindeutig innerhalb des Ordners)

    .Parameter CommandLineExecutable	
        [sr-en] Name of the executable file to launch
        [sr-de] Dateiname der auszuführenden Anwendung

    .Parameter CommandLineArguments	
        [sr-en] Command-line arguments to use when launching the executable
        [sr-de] Befehlszeilenargumente, die beim Starten der ausführbaren Datei verwendet werden

    .Parameter ApplicationGroup
        [sr-en] Application group this application should be associated with
        [sr-de] Anwendungsgruppe, der diese Anwendung zugeordnet wird

    .Parameter DesktopGroup
        [sr-en] Desktop group this application should be associated with
        [sr-de] Desktopgruppe, der diese Anwendung zugeordnet wird

    .Parameter ApplicationType
        [sr-en] Type of the application
        [sr-de] Typ der Anwendung

    .Parameter BrowserName	
        [sr-en] Internal name for this application	
        [sr-de] Interner Name der Anwendung

    .Parameter ClientFolder
        [sr-en] Folder that the application belongs to as the user sees it
        [sr-de] Anwendungskategorie

    .Parameter CpuPriorityLevel
        [sr-en] CPU priority for the launched process      
        [sr-de] CPU Priorität der Anwendung

    .Parameter Description
        [sr-en] Description for the application
        [sr-de] Beschreibung der Anwendung

    .Parameter Enabled
        [sr-en] Application can be launched by end users
        [sr-de] Anwendung kann von Endbenutzern gestartet werden

    .Parameter Visible
        [sr-en] Application is visible to users Y/N
        [sr-de] Anwendung ist für Benutzer sichtbar J/N

    .Parameter HomeZoneOnly	
        [sr-en] Specifies whether if the preferred zone for launching the application is its home zone but no machine is available from that zone then the launch fails
        [sr-de] Start schlägt fehl, wenn die bevorzugte Zone zum Starten der Anwendung die Home-Zone ist, aber kein Rechner aus dieser Zone verfügbar ist

    .Parameter IconFromClient
        [sr-en] The app icon should be retrieved from the application on the client
        [sr-de] App-Symbol soll von der Anwendung auf dem Client abgerufen werden

    .Parameter IgnoreUserHomeZone	
        [sr-en] When launching the application and the user has a home zone specified then the user's home zone preference should be ignored
        [sr-de] Wenn die Anwendung gestartet wird und der Benutzer eine Homezone angegeben hat, sollte die Einstellung der Homezone des Benutzers ignoriert werden

    .Parameter LocalLaunchDisabled	
        [sr-en] When launching a published application from within a published desktop, do not launch the application in that desktop session
        [sr-de] Wenn eine veröffentlichte Anwendung aus einem veröffentlichten Desktop heraus gestartet wird, startet die Anwendung nicht in dieser Desktop-Sitzung

    .Parameter MaxPerMachineInstances	
        [sr-en] Maximum allowed concurrently running instances of the application that an individual machine can have
        [sr-de] Maximal zulässige, gleichzeitig laufende Instanzen der Anwendung, die ein einzelner Rechner haben kann

    .Parameter MaxPerUserInstances	
        [sr-en] Maximum allowed concurrently running instances of the application that an individual user can have
        [sr-de] Maximal zulässige, gleichzeitig laufende Instanzen der Anwendung, die ein einzelner Benutzer haben kann

    .Parameter MaxTotalInstances	
        [sr-en] Maximum allowed total of concurrently running instances of the application in the site
        [sr-de] Maximal zulässige Gesamtzahl der gleichzeitig ausgeführten Instanzen der Anwendung in der Site

    .Parameter PublishedName
        [sr-en] The name seen by end users who have access to this application
        [sr-de] Name, der von Endbenutzern gesehen wird, die Zugriff auf diese Anwendung haben

    .Parameter ShortcutAddedToDesktop	
        [sr-en] Specifies whether or not a shortcut to the application should be placed on the user device
        [sr-de] Verknüpfung zur Anwendung auf dem Benutzergerät platzieren

    .Parameter ShortcutAddedToStartMenu	
        [sr-en] Specifies whether a shortcut to the application should be placed in the user's start menu on their user device
        [sr-de] Verknüpfung zur Anwendung in das Startmenü des Benutzers auf seinem Endgerät legen

    .Parameter StartMenuFolder
        [sr-en] Name of the start menu folder

    .Parameter UserFilterEnabled	
        [sr-en] Specifies whether the application's user filter is enabled or disabled
        [sr-de] Benutzerfilter der Anwendung

    .Parameter WaitForPrinterCreation	
        [sr-en] Specifies whether or not the session waits for the printers to be created before allowing the user to interact with the session
        [sr-de] Sitzung wartet darauf, dass die Drucker erstellt werden, bevor der Benutzer mit der Sitzung interagieren kann

    .Parameter WorkingDirectory	
        [sr-en] Specifies which working directory the executable is launched from
        [sr-de] Arbeitsverzeichnis der ausführbaren Datei 
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ApplicationGroup')]
    [Parameter(Mandatory = $true,ParameterSetName = 'DesktopGroup')]
    [string]$ApplicationName,   
    [Parameter(Mandatory = $true,ParameterSetName = 'ApplicationGroup')]
    [Parameter(Mandatory = $true,ParameterSetName = 'DesktopGroup')]
    [string]$CommandLineExecutable,   
    [Parameter(Mandatory = $true,ParameterSetName = 'ApplicationGroup')]
    [string]$ApplicationGroup,
    [Parameter(Mandatory = $true,ParameterSetName = 'DesktopGroup')]
    [string]$DesktopGroup,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [ValidateSet('HostedOnDesktop','InstalledOnClient','PublishedContent')]
    [string]$ApplicationType,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [string]$CommandLineArguments,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [string]$BrowserName,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [string]$ClientFolder,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [ValidateSet('Low','BelowNormal','Normal','AboveNormal','High')]
    [string]$CpuPriorityLevel,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [string]$Description,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$Enabled,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$Visible,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$HomeZoneOnly,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$IconFromClient,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$IgnoreUserHomeZone,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$LocalLaunchDisabled,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [int]$MaxPerMachineInstances,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [int]$MaxPerUserInstancess,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [int]$MaxTotalInstances,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [string]$PublishedName,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$ShortcutAddedToDesktop,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$ShortcutAddedToStartMenu,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [string]$StartMenuFolder,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$UserFilterEnabled,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [bool]$WaitForPrinterCreation,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [string]$WorkingDirectory,
    [Parameter(ParameterSetName = 'ApplicationGroup')]
    [Parameter(ParameterSetName = 'DesktopGroup')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','PublishedName','Description','Enabled','Visible','UserFilterEnabled')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $ApplicationName
                            'CommandLineExecutable' = $CommandLineExecutable
                            }
                            
    [string]$grpType = 'Application group'
    [string]$grp
    if($PSCmdlet.ParameterSetName -eq 'DesktopGroup'){
        $cmdArgs.Add('DesktopGroup',$DesktopGroup)
        $grpType = 'Desktop group'
        $grp = $DesktopGroup
    }
    else{
        $cmdArgs.Add('ApplicationGroup',$ApplicationGroup)
        $grp = $ApplicationGroup
    }
    if($PSBoundParameters.ContainsKey('CommandLineArguments') -eq $true){
        $cmdArgs.Add('CommandLineArguments',$CommandLineArguments)
    }
    if($PSBoundParameters.ContainsKey('ApplicationType') -eq $true){
        $cmdArgs.Add('ApplicationType',$ApplicationType)
    }
    if($PSBoundParameters.ContainsKey('BrowserName') -eq $true){
        $cmdArgs.Add('BrowserName',$BrowserName)
    }
    if(($ApplicationType -ne 'InstalledOnClient') -and ($PSBoundParameters.ContainsKey('ClientFolder') -eq $true)){
        $cmdArgs.Add('ClientFolder',$ClientFolder)
    }
    if($PSBoundParameters.ContainsKey('CpuPriorityLevel') -eq $true){
        $cmdArgs.Add('CpuPriorityLevel',$CpuPriorityLevel)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('Visible') -eq $true){
        $cmdArgs.Add('Visible',$Visible)
    }
    if($PSBoundParameters.ContainsKey('HomeZoneOnly') -eq $true){
        $cmdArgs.Add('HomeZoneOnly',$HomeZoneOnly)
    }
    if($PSBoundParameters.ContainsKey('IconFromClient') -eq $true){
        $cmdArgs.Add('IconFromClient',$IconFromClient)
    }
    if($PSBoundParameters.ContainsKey('IgnoreUserHomeZone') -eq $true){
        $cmdArgs.Add('IgnoreUserHomeZone',$IgnoreUserHomeZone)
    }
    if($PSBoundParameters.ContainsKey('LocalLaunchDisabled') -eq $true){
        $cmdArgs.Add('LocalLaunchDisabled',$LocalLaunchDisabled)
    }
    if($PSBoundParameters.ContainsKey('MaxPerMachineInstances') -eq $true){
        $cmdArgs.Add('MaxPerMachineInstances',$MaxPerMachineInstances)
    }
    if($PSBoundParameters.ContainsKey('MaxPerUserInstances') -eq $true){
        $cmdArgs.Add('MaxPerUserInstances',$MaxPerUserInstances)
    }
    if($PSBoundParameters.ContainsKey('MaxTotalInstances') -eq $true){
        $cmdArgs.Add('MaxTotalInstances',$MaxTotalInstances)
    }
    if($PSBoundParameters.ContainsKey('PublishedName') -eq $true){
        $cmdArgs.Add('PublishedName',$PublishedName)
    }
    if($PSBoundParameters.ContainsKey('ShortcutAddedToDesktop') -eq $true){
        $cmdArgs.Add('ShortcutAddedToDesktop',$ShortcutAddedToDesktop)
    }
    if($PSBoundParameters.ContainsKey('ShortcutAddedToStartMenu') -eq $true){
        $cmdArgs.Add('ShortcutAddedToStartMenu',$ShortcutAddedToStartMenu)
    }
    if($PSBoundParameters.ContainsKey('StartMenuFolder') -eq $true){
        $cmdArgs.Add('StartMenuFolder',$StartMenuFolder)
    }
    if($PSBoundParameters.ContainsKey('UserFilterEnabled') -eq $true){
        $cmdArgs.Add('UserFilterEnabled',$UserFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('WaitForPrinterCreation') -eq $true){
        $cmdArgs.Add('WaitForPrinterCreation',$WaitForPrinterCreation)
    }
    if($PSBoundParameters.ContainsKey('WorkingDirectory') -eq $true){
        $cmdArgs.Add('WorkingDirectory',$WorkingDirectory)
    }

    StartLogging -ServerAddress $SiteServer -LogText "New Application $($ApplicationName) on $($grpType) $($grp)" -LoggingID ([ref]$LogID)
    $cmdArgs.Add('LoggingId',$LogID)
    
    $null = New-BrokerApplication @cmdArgs
    $ret = Get-BrokerApplication -Name $ApplicationName -AdminAddress $SiteServer -ErrorAction Stop | Select-Object $Properties
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