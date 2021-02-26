#Requires -Version 5.0

<#
    .SYNOPSIS
        Changes properties of application group
    
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
        [sr-en] Name of the application group
        [sr-de] Name der Anwendungsgruppe

    .Parameter Description
        [sr-en] Description for the application group
        [sr-de] Beschreibung der Anwendungsgruppe

    .Parameter Enabled
        [sr-en] Application group's applications can be launched by end users
        [sr-de] Anwendungen der Anwendungsgruppe können von Endbenutzern gestartet werden

    .Parameter SessionSharingEnabled
        [sr-en] Application group's applications can share sessions with applications that are not a member of this application group
        Please note this setting and SingleAppPerSession cannot be true at the same time.
        [sr-de] Anwendungen der Anwendungsgruppe können Sitzungen mit Anwendungen teilen, die nicht Mitglied dieser Anwendungsgruppe sind
        Hinweis: Diese Einstellung und SingleAppPerSession können nicht gleichzeitig aktiv sein

    .Parameter SingleAppPerSession
        [sr-en] Each application launched from this application group starts in its own new session or can share an existing suitable session if present
        [sr-de] Jede Anwendung, die von dieser Anwendungsgruppe gestartet wird, startet in einer eigenen neuen Sitzung oder kann eine bestehende geeignete Sitzung teilen, falls vorhanden

    .Parameter UserFilterEnabled	
        [sr-en] Enabled or disabled the application group's user filter
        [sr-de] Aktiviert oder deaktiviert den Benutzerfilter der Anwendungsgruppe
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$SiteServer,
    [string]$Description,
    [bool]$Enabled,
    [bool]$SessionSharingEnabled,
    [bool]$SingleAppPerSession,
    [bool]$UserFilterEnabled
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Description','Enabled','UserFilterEnabled','SessionSharingEnabled','SingleAppPerSession','Uid')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Change Application Group $($Name)" -LoggingID ([ref]$LogID)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'Name' = $Name
                            'PassThru' = $null
                            }
    
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('SessionSharingEnabled') -eq $true){
        $cmdArgs.Add('SessionSharingEnabled',$SessionSharingEnabled)
    }
    if($PSBoundParameters.ContainsKey('SingleAppPerSession') -eq $true){
        $cmdArgs.Add('SingleAppPerSession',$SingleAppPerSession)
    }
    if($PSBoundParameters.ContainsKey('UserFilterEnabled') -eq $true){
        $cmdArgs.Add('UserFilterEnabled',$UserFilterEnabled)
    }

    $ret = Set-BrokerApplicationGroup @cmdArgs | Select-Object $Properties        
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