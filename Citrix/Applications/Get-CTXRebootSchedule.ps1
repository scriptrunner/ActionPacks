#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets one or more reboot schedules
    
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

    .Parameter Uid
        [sr-en] Reboot schedule with the specified value of Uid
        [sr-de] Neustartzeitplan mit dieser Uid

    .Parameter RebootScheduleName
        [sr-en] Reboot schedule with the specified name
        [sr-de] Neustartzeitplan mit dem angegebenen Namen

    .Parameter Active	
        [sr-en] Desktop group reboot schedules according to whether they are currently active or not
        [sr-de] Aktive/deaktivierte Neustartzeitpläne

    .Parameter Enabled	
        [sr-en] Reboot schedule with the specified value
        [sr-de] Neustartzeitpläne mit der angegebenen Wert 

    .Parameter Day	
        [sr-en] Reboot schedules set to run on the specific day of week
        [sr-de] Neustartzeitpläne die für diesen Wochentag konfiguriert sind

    .Parameter DayInMonth	
        [sr-en] Reboot schedules set to run on the specific day in month
        [sr-de] Neustartzeitpläne die für diesen Tag konfiguriert sind

    .Parameter DesktopGroupUid	
        [sr-en] Reboot schedules for the desktop group having this Uid
        [sr-de] Neustartzeitpläne dieser Bereitstellungsgruppe

    .Parameter MaxOvertimeStartMins	
        [sr-en] Maximum delay in minutes after which the scheduled reboot will not take place
        [sr-de] Maximale Verzögerung in Minuten, nach der der geplante Neustart nicht mehr durchgeführt wird

    .Parameter Frequency	
        [sr-en] Reboot schedules with the specified frequency
        [sr-de] Neustartzeitpläne mit der angegebenen Häufigkeit

    .Parameter FrequencyFactor	
        [sr-en] Reboot schedules with the specified frequency factor
        [sr-de] Neustartzeitpläne mit dem angegebenen Faktor

    .Parameter IgnoreMaintenanceMode	
        [sr-en] Reboot machines in maintenance mode
        [sr-de] Neustartzeitpläne mit Neustart im Wartungsmodus

    .Parameter RebootDuration	
        [sr-en] Reboot schedules with the specified duration
        [sr-de] Neustartzeitpläne mit der angegebenen Dauer

    .Parameter RestrictToTag	
        [sr-en] Reboot schedules with the specified tag
        [sr-de] Neustartzeitpläne mit dem angegebenen Tag

    .Parameter UseNaturalReboot	
        [sr-en] Reboot schedules with the specified value
        [sr-de] Neustartzeitpläne mit dem angegebenen Wert

    .Parameter WarningRepeatInterval	
        [sr-en] Reboot schedules with the specified warning repeat interval
        [sr-de] Neustartzeitpläne mit dem Warnung Wiederholungsintervall

    .Parameter WeekInMonth	
        [sr-en] Reboot schedules with the specified week in a month
        [sr-de] Neustartzeitpläne die für diesen Woche konfiguriert sind

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>
	  
param( 
    [string]$SiteServer,
    [string]$Uid,
    [string]$RebootScheduleName,
    [bool]$Active,
    [bool]$Enabled,
    [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
    [string[]]$Day,
    [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
    [string]$DayInMonth,
    [int]$DesktopGroupUid,
    [ValidateSet('Weekly','Daily','Monthly')]
    [string]$Frequency,
    [int]$FrequencyFactor,
    [bool]$IgnoreMaintenanceMode,
    [int]$MaxOvertimeStartMins,
    [int]$RebootDuration,
    [string]$RestrictToTag,
    [bool]$UseNaturalReboot,
    [int]$WarningRepeatInterval,
    [ValidateSet('First','Second','Third','Fourth','Last')]
    [string]$WeekInMonth,
    [ValidateSet('*','Name','Description','Active','Enabled','Day','DayInMonth','DesktopGroupName','DesktopGroupUid',
                'Frequency','FrequencyFactor','IgnoreMaintenanceMode','MaxOvertimeStartMins','RebootDuration','RestrictToTag',
                'StartDate','StartTime','Uid','UseNaturalReboot','WarningDuration','WarningMessage','WarningRepeatInterval','WarningTitle','WeekInMonth')]
    [string[]]$Properties = @('Name','Description','Active','Enabled','DesktopGroupName','Frequency','IgnoreMaintenanceMode','Uid')
) 

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Property' = $Properties
                            }
    
    if([System.String]::IsNullOrWhiteSpace($Uid) -eq $false){
        $cmdArgs.Add('Uid',$Uid)
    }
    if($PSBoundParameters.ContainsKey('RebootScheduleName') -eq $true){
        $cmdArgs.Add('RebootScheduleName',$RebootScheduleName)
    }
    if($PSBoundParameters.ContainsKey('Active') -eq $true){
        $cmdArgs.Add('Active',$Active)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('DesktopGroupUid') -eq $true){
        $cmdArgs.Add('DesktopGroupUid',$DesktopGroupUid)
    }
    if($PSBoundParameters.ContainsKey('Day') -eq $true){
        $cmdArgs.Add('Day',($Day -join ','))
    }
    if($PSBoundParameters.ContainsKey('DayInMonth') -eq $true){
        $cmdArgs.Add('DayInMonth',$DayInMonth)
    }
    if($FrequencyFactor -gt 0){
        $cmdArgs.Add('FrequencyFactor',$FrequencyFactor)
    }
    if($MaxOvertimeStartMins -gt 0){
        $cmdArgs.Add('MaxOvertimeStartMins',$MaxOvertimeStartMins)
    }
    if($RebootDuration -gt 0){
        $cmdArgs.Add('RebootDuration',$RebootDuration)
    }
    if($WarningRepeatInterval -gt 0){
        $cmdArgs.Add('WarningRepeatInterval',$WarningRepeatInterval)
    }
    if($PSBoundParameters.ContainsKey('Frequency') -eq $true){
        $cmdArgs.Add('Frequency',$Frequency)
    }
    if($PSBoundParameters.ContainsKey('IgnoreMaintenanceMode') -eq $true){
        $cmdArgs.Add('IgnoreMaintenanceMode',$IgnoreMaintenanceMode)
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

    $ret = Get-BrokerRebootScheduleV2 @cmdArgs | Select-Object $Properties | Sort-Object Name

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