#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates and starts a reboot cycle for each specified desktop group
    
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

    .Parameter DesktopGroupUid	
        [sr-en] Creates a reboot cycle for each desktop group that contains machines from this catalog
        [sr-de] Erzeugt einen Neustart-Zyklus für jede Desktop-Gruppe, die Rechner aus diesem Katalog enthält

    .Parameter RebootDuration	
        [sr-en] Approximate maximum number of minutes over which the scheduled reboot cycle runs
        [sr-de] Maximale Anzahl von Minuten, über die der geplante Neustartzeitplan läuft

    .Parameter IgnoreMaintenanceMode	
        [sr-en] Reboot machines in maintenance mode
        [sr-de] Neustart von Maschinen im Wartungsmodus

    .Parameter WarningDuration
        [sr-en] Time prior to the initiation of a machine reboot at which warning message is displayed in all user sessions on that machine
        [sr-de] Zeitpunkt vor dem Neustart des Rechners, zu dem die Warnmeldung in allen Benutzersitzungen auf diesem Rechner angezeigt wird

    .Parameter WarningMessage
        [sr-en] Warning message displayed in user sessions on a machine scheduled for reboot
        [sr-de] Warnmeldung, die in Benutzersitzungen auf einem zum Neustart vorgesehenen Computer angezeigt wird

    .Parameter WarningRepeatInterval	
        [sr-en] Time to wait after the previous reboot warning before displaying the warning message in all user sessions on that machine again
        [sr-de] Zeit, die nach der letzten Neustart-Warnung gewartet wird, bevor die Warnmeldung in allen Benutzersitzungen auf diesem Computer wieder angezeigt wird

    .Parameter WarningTitle	
        [sr-en] Window title used when showing the warning message in user sessions on a machine scheduled for reboot
        [sr-de] Fenstertitel, der verwendet wird, wenn die Warnmeldung in Benutzersitzungen auf einem zum Neustart vorgesehenen Rechner angezeigt wird
#>
	  
param( 
    [Parameter(Mandatory = $true)]
    [string]$DesktopGroupUid,
    [Parameter(Mandatory = $true)]
    [int]$RebootDuration,
    [string]$SiteServer,
    [int]$WarningDuration,
    [string]$WarningMessage,
    [string]$WarningTitle,
    [int]$WarningRepeatInterval,
    [bool]$IgnoreMaintenanceMode
) 

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    StartLogging -ServerAddress $SiteServer -LogText "Start desktop group reboot cycle" -LoggingID ([ref]$LogID)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'RebootDuration' = $RebootDuration
                            }
    
    if($PSBoundParameters.ContainsKey('WarningMessage') -eq $true){
        $cmdArgs.Add('WarningMessage',$WarningMessage)
    }
    if($PSBoundParameters.ContainsKey('WarningTitle') -eq $true){
        $cmdArgs.Add('WarningTitle',$WarningTitle)
    }
    if($WarningRepeatInterval -gt 0){
        $cmdArgs.Add('WarningRepeatInterval',$WarningRepeatInterval)
    }
    if($WarningDuration -gt 0){
        $cmdArgs.Add('WarningDuration',$WarningDuration)
    }
    if($PSBoundParameters.ContainsKey('IgnoreMaintenanceMode') -eq $true){
        $cmdArgs.Add('IgnoreMaintenanceMode',$IgnoreMaintenanceMode)
    }

    $ret = Get-BrokerDesktopGroup -Uid $DesktopGroupUid | Start-BrokerDesktopGroupRebootCycle @cmdArgs | Select-Object *
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