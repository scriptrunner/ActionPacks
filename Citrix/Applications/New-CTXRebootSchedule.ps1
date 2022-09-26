#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a new reboot schedule for a desktop group
    
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
        [sr-en] Uid of the desktop group that this reboot schedule is applied to
        [sr-de] Uid dieser Bereitstellungsgruppe

    .Parameter RebootScheduleName
        [sr-en] Name of the new reboot schedule
        [sr-de] Name des neuen Neustartzeitplan

    .Parameter RebootDuration	
        [sr-en] Approximate maximum number of minutes over which the scheduled reboot cycle runs
        [sr-de] Maximale Anzahl von Minuten, über die der geplante Neustartzeitplan läuft

    .Parameter Description	
        [sr-en] Description for the reboot schedule
        [sr-de] Beschreibung

    .Parameter Enabled	
        [sr-en] Reboot schedule is enabled
        [sr-de] Neustartzeitplan aktivieren

    .Parameter Day	
        [sr-en] Days of the week on which the scheduled reboot-cycle starts
        [sr-de] Wochentage an denen der Neustartzeitplan ausgeführt wird

    .Parameter DayInMonth	
        [sr-en] Reboot schedules set to run on the specified day in month.
        [sr-de] Neustartzeitplan an diesen Tag konfiguriert sind

    .Parameter Frequency	
        [sr-en] Frequency with which this schedule runs
        [sr-de] Häufigkeit der Ausführung des Neustartzeitplans

    .Parameter FrequencyFactor	
        [sr-en] Frequency factor for the reboot schedule
        [sr-de] Faktor für die Ausführung des Neustartzeitplans

    .Parameter IgnoreMaintenanceMode	
        [sr-en] Reboot machines in maintenance mode
        [sr-de] Neustart von Maschinen im Wartungsmodus

    .Parameter MaxOvertimeStartMins	
        [sr-en] Maximum delay in minutes after which the scheduled reboot will not take place
        [sr-de] Maximale Verzögerung in Minuten, nach der der geplante Neustart nicht mehr durchgeführt wird

    .Parameter RestrictToTag	
        [sr-en] Reboot schedule only applies to machines in the desktop group with the specified tag
        [sr-de] Neustartzeitplan nur für Maschinen mit dem angegebenen Tag

    .Parameter UseNaturalReboot	
        [sr-en] Machines should reboot whenever they happen to have no sessions, rather than at equally spaced times within the cycle duration
        [sr-de] Maschinen immer dann neu starten, wenn sie gerade keine Sitzungen haben, und nicht in gleichmäßigen Abständen innerhalb der Zyklusdauer

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

    .Parameter WeekInMonth	
        [sr-en] For monthly schedules, the week in the month on which the scheduled reboot-cycle starts
        [sr-de] Bei monatlichen Zeitplänen die Woche im Monat, in der der geplante Neustart-Zyklus beginnt

    .Parameter StartDateTime
        [sr-en] Date and time on which the first schedule is expected to run
        [sr-de] Datum und Zeitpunkt an dem der Neustart erstmals durchgeführt wird
#>
	  
param( 
    [Parameter(Mandatory = $true)]
    [string]$RebootScheduleName,
    [Parameter(Mandatory = $true)]
    [int]$RebootDuration,
    [Parameter(Mandatory = $true)]
    [int]$DesktopGroupUid,
    [string]$SiteServer,
    [string]$Description,
    [bool]$Enabled,
    [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
    [string[]]$Day,
    [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
    [string]$DayInMonth,
    [ValidateSet('Weekly','Daily','Monthly')]
    [string]$Frequency,
    [int]$FrequencyFactor,
    [bool]$IgnoreMaintenanceMode,
    [int]$MaxOvertimeStartMins,
    [string]$RestrictToTag,
    [bool]$UseNaturalReboot,
    [int]$WarningDuration,
    [string]$WarningMessage,
    [string]$WarningTitle,
    [int]$WarningRepeatInterval,
    [ValidateSet('First','Second','Third','Fourth','Last')]
    [string]$WeekInMonth,
    [datetime]$StartDateTime
) 

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    [string[]]$Properties = @('Name','Description','Active','Enabled','DesktopGroupName','Frequency','IgnoreMaintenanceMode','Uid')
    
    StartLogging -ServerAddress $SiteServer -LogText "Create Reboot schedule $($RebootScheduleName)" -LoggingID ([ref]$LogID)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingId' = $LogID
                            'Name' = $RebootScheduleName
                            'RebootDuration' = $RebootDuration
                            'DesktopGroupUid' = $DesktopGroupUid
                            }
    
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('Day') -eq $true){
        $cmdArgs.Add('Day',($Day -join ','))
    }
    if($PSBoundParameters.ContainsKey('DayInMonth') -eq $true){
        $cmdArgs.Add('DayInMonth',$DayInMonth)
    }
    if($PSBoundParameters.ContainsKey('Frequency') -eq $true){
        $cmdArgs.Add('Frequency',$Frequency)
    }
    if($FrequencyFactor -gt 0){
        $cmdArgs.Add('FrequencyFactor',$FrequencyFactor)
    }
    if($PSBoundParameters.ContainsKey('IgnoreMaintenanceMode') -eq $true){
        $cmdArgs.Add('IgnoreMaintenanceMode',$IgnoreMaintenanceMode)
    }
    if($PSBoundParameters.ContainsKey('WarningMessage') -eq $true){
        $cmdArgs.Add('WarningMessage',$WarningMessage)
    }
    if($PSBoundParameters.ContainsKey('WarningTitle') -eq $true){
        $cmdArgs.Add('WarningTitle',$WarningTitle)
    }
    if($MaxOvertimeStartMins -gt 0){
        $cmdArgs.Add('MaxOvertimeStartMins',$MaxOvertimeStartMins)
    }
    if($WarningRepeatInterval -gt 0){
        $cmdArgs.Add('WarningRepeatInterval',$WarningRepeatInterval)
    }
    if($WarningDuration -gt 0){
        $cmdArgs.Add('WarningDuration',$WarningDuration)
    }
    if($PSBoundParameters.ContainsKey('UseNaturalReboot') -eq $true){
        $cmdArgs.Add('UseNaturalReboot',$UseNaturalReboot)
    }
    if($PSBoundParameters.ContainsKey('RestrictToTag') -eq $true){
        $cmdArgs.Add('RestrictToTag',$RestrictToTag)
    }
    if($PSBoundParameters.ContainsKey('WeekInMonth') -eq $true){
        $cmdArgs.Add('WeekInMonth',$WeekInMonth)
    }
    if($null -ne $StartDateTime){
        $cmdArgs.Add('StartDate',$StartDateTime.ToString("yyyy-MM-dd"))
        $cmdArgs.Add('StartTime',$StartDateTime.ToString("HH:mm"))
    }

    $ret = New-BrokerRebootScheduleV2 @cmdArgs | Select-Object $Properties
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