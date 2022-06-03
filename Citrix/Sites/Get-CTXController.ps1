#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets Controllers running broker services in the site
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Sites
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter ControllerVersion
        [sr-en] Only Controllers running the specified version of the broker service
        [sr-de] Nur Controller, auf denen die angegebene Version des Broker-Dienstes läuft

    .Parameter DNSName
        [sr-en] Only Controllers with the specified DNS name ('machine.domain')
        [sr-de] Nur Controller, mit dem angegebenen DNS Namen ('maschine.domäne')

    .Parameter LastLicensingServerEvent
        [sr-en] Only Controllers with the specified last license server event recorded
        [sr-de] Nur Controller, mit diesem angegebenen Lizenzserver-Ereignis

    .Parameter LicensingGraceState
        [sr-en] Only Controllers in the specified licensing grace state
        [sr-de] Nur Controller im angegebenen Lizenzierungsstatus (Grace)

    .Parameter LicensingServerState
        [sr-en] Only Controllers in the specified licensing server state
        [sr-de] Nur Controller mit dem angegebenen Status des Lizenzierungsservers

    .Parameter OSType
        [sr-en] Only Controllers running the specified Operating System type
        [sr-de] Nur Controller mit dem angegebenen Betriebssystem

    .Parameter OSVersion
        [sr-en] Only Controllers running the specified Operating System version
        [sr-de] Nur Controller mit der angegebenen Version des Betriebssystems

    .Parameter State
        [sr-en] Only Controllers currently in the specified state
        [sr-de] Nur Controller mit dem angegebenen Status

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$SiteServer,
    [string]$ControllerVersion,
    [string]$DNSName,
    [ValidateSet('CheckinFailed','CheckoutFailed','EmergencyGracePeriodEntered','EmergencyGracePeriodExpired','IncompleteConfiguration','InitializationError',
                'LicenseAvailabilityCheckError','LicenseExpired','NoLicenseAvailable','NotificationProfileReadError','OutOfBoxGracePeriodEntered','OutOfBoxGracePeriodExpired',
                'OverdraftGranted','ProductLicenseNotInstalled','ReinitializationError','ServerIncompatible','ServerOK','ShutdownError',
                'StartupLicenseNotInstalled','SupplementalGracePeriodEntered','SupplementalGracePeriodExpired')]
    [string]$LastLicensingServerEvent,
    [ValidateSet('NotActive','InOutOfBoxGracePeriod','InSupplementalGracePeriod','InEmergencyGracePeriod','GracePeriodExpired')]
    [string]$LicensingGraceState,
    [ValidateSet('ServerNotSpecified','NotConnected','OK','LicenseNotInstalled','LicenseExpired','Incompatible','Failed')]
    [string]$LicensingServerState,
    [string]$OSType,
    [string]$OSVersion,
    [ValidateSet('Failed','Off','On','Active')]
    [string]$State,
    [int]$MaxRecordCount = 250,
    [ValidateSet('*','DNSName','MachineName','LastActivityTime','LastLicensingServerEvent','LastStartTime','LastLicensingServerEventTime','LicensingServerState','State','OSType','OSVersion','SID','UUID','Uid')]
    [string[]]$Properties = @('DNSName','MachineName','LastActivityTime','LastLicensingServerEvent','LastStartTime','LastLicensingServerEventTime','LicensingServerState','State')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }    

    if($PSBoundParameters.ContainsKey('DNSName') -eq $true){
        $cmdArgs.Add('DNSName',$DNSName)
    }
    if($PSBoundParameters.ContainsKey('ControllerVersion') -eq $true){
        $cmdArgs.Add('ControllerVersion',$ControllerVersion)
    }
    if($PSBoundParameters.ContainsKey('LastLicensingServerEvent') -eq $true){
        $cmdArgs.Add('LastLicensingServerEvent',$LastLicensingServerEvent)
    }
    if($PSBoundParameters.ContainsKey('LicensingGraceState') -eq $true){
        $cmdArgs.Add('LicensingGraceState',$LicensingGraceState)
    }
    if($PSBoundParameters.ContainsKey('LicensingServerState') -eq $true){
        $cmdArgs.Add('LicensingServerState',$LicensingServerState)
    }
    if($PSBoundParameters.ContainsKey('OSType') -eq $true){
        $cmdArgs.Add('OSType',$OSType)
    }
    if($PSBoundParameters.ContainsKey('OSVersion') -eq $true){
        $cmdArgs.Add('OSVersion',$OSVersion)
    }
    if($PSBoundParameters.ContainsKey('State') -eq $true){
        $cmdArgs.Add('State',$State)
    }
    
    $ret = Get-BrokerController @cmdArgs | Select-Object $Properties
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
    CloseCitrixSession
}