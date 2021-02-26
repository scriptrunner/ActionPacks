#Requires -Version 5.0

<#
    .SYNOPSIS
        Changes properties of an application 
    
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
        [sr-en] Name of the application
        [sr-de] Name der Anwendung

    .Parameter Description
        [sr-en] Description for the application
        [sr-de] Beschreibung der Anwendung

    .Parameter Enabled
        [sr-en] Application can be launched by end users
        [sr-de] Anwendung kann von Endbenutzern gestartet werden

    .Parameter Visible
        [sr-en] Application is visible to users Y/N
        [sr-de] Anwendung ist für Benutzer sichtbar J/N

    .Parameter UserFilterEnabled
        [sr-en] Enable or disable the application's user filter
        [sr-de] Benutzerfilter der Anwendung aktivieren J/N

    .Parameter ClientFolder
        [sr-en] The folder that the application belongs to as the user sees it
        [sr-de] Anwendungskategorie

    .Parameter CommandLineArguments
        [sr-en] Command-line arguments to use when launching the executable
        [sr-de] Befehlszeilenargumente, die beim Starten der ausführbaren Datei verwendet werden

    .Parameter IconFromClient
        [sr-en] If the app icon should be retrieved from the application on the client
        [sr-de] Anwendungssymbol aus der Anwendung auf dem Client abrufen

    .Parameter IgnoreUserHomeZone
        [sr-en] When launching the application and the user has a home zone specified then the user's home zone preference should be ignored
        [sr-de] Wird die Anwendung gestartet, wird die Home-Zonen-Einstellung des Benutzers ignoriert

    .Parameter LocalLaunchDisabled	
        [sr-en] When launching a published application from within a published desktop, do not launch the application in that desktop session
        [sr-de] Beim Start einer veröffentlichten Anwendung von einem veröffentlichten Desktop aus, startet die Anwendung nicht in dieser Desktop-Sitzung

    .Parameter MaxTotalInstances	
        [sr-en] Maximum allowed total of concurrently running instances of the application in the site
        [sr-de] Maximal zulässige Gesamtzahl gleichzeitig laufender Instanzen der Anwendung in der Site

    .Parameter PublishedName	
        [sr-en] The name seen by end users who have access to this application
        [sr-de] Der Name, der von Endbenutzern gesehen wird, die Zugang zu dieser Anwendung haben

    .Parameter SecureCmdLineArgumentsEnabled	
        [sr-en] The command-line arguments should be secured
        [sr-de] Die Kommandozeilenargumente werden gesichert J/N
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$SiteServer,
    [string]$PublishedName,
    [string]$Description,
    [bool]$Enabled,
    [bool]$Visible,
    [string]$ClientFolder,
    [string]$CommandLineArguments,
    [bool]$UserFilterEnabled,
    [bool]$IconFromClient,
    [bool]$IgnoreUserHomeZone,
    [bool]$LocalLaunchDisabled,
    [bool]$SecureCmdLineArgumentsEnabled,
    [int]$MaxTotalInstances
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','PublishedName','Description','Enabled','Visible','Uid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Change Application $($Name)" -LoggingID ([ref]$LogID)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'Name' = $Name
                            'PassThru' = $null
                            }
    
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('PublishedName') -eq $true){
        $cmdArgs.Add('PublishedName',$PublishedName)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('Visible') -eq $true){
        $cmdArgs.Add('Visible',$Visible)
    }
    if($PSBoundParameters.ContainsKey('ClientFolder') -eq $true){
        $cmdArgs.Add('ClientFolder',$ClientFolder)
    }
    if($PSBoundParameters.ContainsKey('CommandLineArguments') -eq $true){
        $cmdArgs.Add('CommandLineArguments',$CommandLineArguments)
    }
    if($PSBoundParameters.ContainsKey('UserFilterEnabled') -eq $true){
        $cmdArgs.Add('UserFilterEnabled',$UserFilterEnabled)
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
    if($PSBoundParameters.ContainsKey('MaxTotalInstances') -eq $true){
        $cmdArgs.Add('MaxTotalInstances',$MaxTotalInstances)
    }
    if($PSBoundParameters.ContainsKey('SecureCmdLineArgumentsEnabled') -eq $true){
        $cmdArgs.Add('SecureCmdLineArgumentsEnabled',$SecureCmdLineArgumentsEnabled)
    }

    $ret = Set-BrokerApplication @cmdArgs | Select-Object $Properties        
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