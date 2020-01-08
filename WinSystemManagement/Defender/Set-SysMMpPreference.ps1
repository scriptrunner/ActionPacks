#Requires -Version 4.0

<#
.SYNOPSIS
    Configures preferences for Windows Defender scans and updates

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Defender

.Parameter ExclusionExtension    
    Specifies, comma separated, file name extensions, such as obj or lib, to exclude from scheduled, custom, and real-time scanning

.Parameter ExclusionPath
    Specifies, comma separated, file paths to exclude from scheduled and real-time scanning. 
    You can specify a folder to exclude all the files under the folder

.Parameter CheckForSignaturesBeforeRunningScan
     Indicates whether to check for new virus and spyware definitions before Windows Defender runs a scan

.Parameter DisableArchiveScanning
    Indicates whether to scan archive files, such as .zip and .cab files, for malicious and unwanted software

.Parameter DisableAutoExclusions
    Indicates whether to disable the Automatic Exclusions feature for the server

.Parameter DisableBehaviorMonitoring
    Indicates whether to enable behavior monitoring

.Parameter DisableCatchupFullScan
    Indicates whether Windows Defender runs catch-up scans for scheduled full scans

.Parameter DisableCatchupQuickScan
    Indicates whether Windows Defender runs catch-up scans for scheduled quick scans

.Parameter DisableEmailScanning
    Indicates whether Windows Defender parses the mailbox and mail files, according to their specific format, in order to analyze mail bodies and attachments

.Parameter DisableIOAVProtection
    Indicates whether Windows Defender scans all downloaded files and attachments

.Parameter DisableIntrusionPreventionSystem
    Indicates whether to configure network protection against exploitation of known vulnerabilities

.Parameter DisablePrivacyMode
    Indicates whether to disable privacy mode

.Parameter DisableRealtimeMonitoring
    Indicates whether to use real-time protection

.Parameter DisableRemovableDriveScanning
    Indicates whether to scan for malicious and unwanted software in removable drives, such as flash drives, during a full scan

.Parameter DisableRestorePoint
    Indicates whether to disable scanning of restore points

.Parameter DisableScanningMappedNetworkDrivesForFullScan
     Indicates whether to scan mapped network drives

.Parameter DisableScanningNetworkFiles
    Indicates whether to scan for network files

.Parameter DisableScriptScanning
     Specifies whether to disable the scanning of scripts during malware scans

.Parameter HighThreatDefaultAction
    Specifies which automatic remediation action to take for a high level threat
    
.Parameter LowThreatDefaultAction
    Specifies which automatic remediation action to take for a low level threat
    
.Parameter ModerateThreatDefaultAction
    Specifies which automatic remediation action to take for a moderate level threat

.Parameter SevereThreatDefaultAction
    Specifies which automatic remediation action to take for a severe level threat

.Parameter MAPSReporting 
    Specifies the type of membership in Microsoft Active Protection Service

.Parameter QuarantinePurgeItemsAfterDelay
    Specifies the number of days to keep items in the Quarantine folder

.Parameter RandomizeScheduleTaskTimes
    Indicates whether to select a random time for the scheduled start and scheduled update for definitions

.Parameter RealTimeScanDirection
    Specifies scanning configuration for incoming and outgoing files on NTFS volumes

.Parameter RemediationScheduleDay
    Specifies the day of the week on which to perform a scheduled full scan in order to complete remediation

.Parameter ReportingAdditionalActionTimeOut
    Specifies the number of minutes before a detection in the additional action state changes to the cleared state

.Parameter ReportingCriticalFailureTimeOut
    Specifies the number of minutes before a detection in the critically failed state changes to either the additional action state or the cleared state

.Parameter ReportingNonCriticalTimeOut
    Specifies the number of minutes before a detection in the non-critically failed state changes to the cleared state

.Parameter ScanAvgCPULoadFactor
    Specifies the maximum percentage CPU usage for a scan

.Parameter ScanOnlyIfIdleEnabled
    Indicates whether to start scheduled scans only when the computer is not in use

.Parameter ScanParameters
    Specifies the scan type to use during a scheduled scan

.Parameter ScanPurgeItemsAfterDelay
    Specifies the number of days to keep items in the scan history folder

.Parameter ScanScheduleDay
    Specifies the day of the week on which to perform a scheduled scan

.Parameter SignatureAuGracePeriod
    Specifies a grace period, in minutes, for the definition. If a definition successfully updates within this period, Windows Defender abandons any service initiated updates

.Parameter SignatureDisableUpdateOnStartupWithoutEngine
    Indicates whether to initiate definition updates even if no antimalware engine is present

.Parameter SignatureFirstAuGracePeriod
    Specifies a grace period, in minutes, for the definition

.Parameter SignatureScheduleDay
    Specifies the day of the week on which to check for definition updates

.Parameter SignatureUpdateCatchupInterval
    Specifies the number of days after which Windows Defender requires a catch-up definition update

.Parameter SignatureUpdateInterval
    Specifies the interval, in hours, at which to check for definition updates

.Parameter SubmitSamplesConsent
    Specifies how Windows Defender checks for user consent for certain samples

.Parameter UILockdown
    Indicates whether to disable UI lockdown mode

.Parameter UnknownThreatDefaultAction
    Specifies which automatic remediation action to take for an unknown level threat

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ExclusionExtension,
    [string]$ExclusionPath,
    [bool]$CheckForSignaturesBeforeRunningScan,
    [bool]$DisableArchiveScanning,
    [bool]$DisableAutoExclusions,
    [bool]$DisableBehaviorMonitoring,
    [bool]$DisableCatchupFullScan,
    [bool]$DisableCatchupQuickScan,
    [bool]$DisableEmailScanning,
    [bool]$DisableIOAVProtection,
    [bool]$DisableIntrusionPreventionSystem,
    [bool]$DisablePrivacyMode,
    [bool]$DisableRealtimeMonitoring,
    [bool]$DisableRemovableDriveScanning,
    [bool]$DisableRestorePoint,
    [bool]$DisableScanningMappedNetworkDrivesForFullScan,
    [bool]$DisableScanningNetworkFiles,
    [bool]$DisableScriptScanning,
    [Validateset("Quarantine", "Remove","Ignore")]
    [string]$HighThreatDefaultAction,
    [Validateset("Quarantine", "Remove","Ignore")]
    [string]$LowThreatDefaultAction,
    [Validateset("Quarantine", "Remove","Ignore")]
    [string]$ModerateThreatDefaultAction,
    [Validateset("Quarantine", "Remove","Ignore")]
    [string]$SevereThreatDefaultAction,
    [Validateset("Quarantine", "Remove","Ignore")]
    [string]$UnknownThreatDefaultAction,
    [Validateset("Disabled", "Basic","Advanced")]
    [string]$MAPSReporting,
    [uint32]$QuarantinePurgeItemsAfterDelay,
    [bool]$RandomizeScheduleTaskTimes,
    [Validateset("Both", "Incoming","Outcoming")]
    [string]$RealTimeScanDirection,
    [Validateset("Everyday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Never")]
    [string]$RemediationScheduleDay,
    [uint32]$ReportingAdditionalActionTimeOut,
    [uint32]$ReportingCriticalFailureTimeOut,
    [uint32]$ReportingNonCriticalTimeOut,
    [int]$ScanAvgCPULoadFactor,
    [bool]$ScanOnlyIfIdleEnabled,
    [ValidateSet("Quickscan", "FullScan")]
    [string]$ScanParameters,
    [uint32]$ScanPurgeItemsAfterDelay,
    [Validateset("Everyday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Never")]
    [string]$ScanScheduleDay,
    [uint32]$SignatureAuGracePeriod,
    [bool]$SignatureDisableUpdateOnStartupWithoutEngine,
    [uint32]$SignatureFirstAuGracePeriod,
    [Validateset("Everyday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Never")]
    [string]$SignatureScheduleDay,
    [uint32]$SignatureUpdateCatchupInterval,
    [uint32]$SignatureUpdateInterval,
    [Validateset("None", "Always","Never")]
    [string]$SubmitSamplesConsent,
    [bool]$UILockdown,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ExclusionExtension') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ExclusionExtension $ExclusionExtension.Split(",") -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ExclusionPath') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ExclusionPath $ExclusionPath.Split(",") -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HighThreatDefaultAction') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim  -HighThreatDefaultAction $HighThreatDefaultAction -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('LowThreatDefaultAction') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim  -LowThreatDefaultAction $LowThreatDefaultAction -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ModerateThreatDefaultAction') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim  -ModerateThreatDefaultAction $ModerateThreatDefaultAction -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SevereThreatDefaultAction') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -SevereThreatDefaultAction $SevereThreatDefaultAction -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('UnknownThreatDefaultAction') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -UnknownThreatDefaultAction $UnknownThreatDefaultAction -Force -ErrorAction Stop
    }    
    if($PSBoundParameters.ContainsKey('CheckForSignaturesBeforeRunningScan') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -CheckForSignaturesBeforeRunningScan $CheckForSignaturesBeforeRunningScan -Force -ErrorAction Stop
    }    
    if($PSBoundParameters.ContainsKey('DisableArchiveScanning') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableArchiveScanning $DisableArchiveScanning -Force -ErrorAction Stop
    }    
    if($PSBoundParameters.ContainsKey('DisableAutoExclusions') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableAutoExclusions $DisableAutoExclusions -Force -ErrorAction Stop
    }    
    if($PSBoundParameters.ContainsKey('DisableBehaviorMonitoring') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableBehaviorMonitoring $DisableBehaviorMonitoring -Force -ErrorAction Stop
    }    
    if($PSBoundParameters.ContainsKey('DisableCatchupFullScan') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableCatchupFullScan $DisableCatchupFullScan -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableCatchupQuickScan') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableCatchupQuickScan $DisableCatchupQuickScan -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableEmailScanning') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableEmailScanning $DisableEmailScanning -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableIOAVProtection') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableIOAVProtection $DisableIOAVProtection -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableIntrusionPreventionSystem') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableIntrusionPreventionSystem $DisableIntrusionPreventionSystem -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisablePrivacyMode') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisablePrivacyMode $DisablePrivacyMode -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableRealtimeMonitoring') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableRealtimeMonitoring $DisableRealtimeMonitoring -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableRemovableDriveScanning') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableRemovableDriveScanning $DisableRemovableDriveScanning -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableRestorePoint') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableRestorePoint $DisableRestorePoint -Force -ErrorAction Stop    
    }
    if($PSBoundParameters.ContainsKey('DisableScanningMappedNetworkDrivesForFullScan') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableScanningMappedNetworkDrivesForFullScan $DisableScanningMappedNetworkDrivesForFullScan -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableScanningNetworkFiles') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableScanningNetworkFiles $DisableScanningNetworkFiles -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisableScriptScanning') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -DisableScriptScanning $DisableScriptScanning -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('MAPSReporting') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -MAPSReporting $MAPSReporting -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('QuarantinePurgeItemsAfterDelay') -eq $true ){
        $null =  Set-MpPreference -CimSession $Script:Cim -QuarantinePurgeItemsAfterDelay $QuarantinePurgeItemsAfterDelay -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('RealTimeScanDirection') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -RealTimeScanDirection $RealTimeScanDirection -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('RandomizeScheduleTaskTimes') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -RandomizeScheduleTaskTimes $RandomizeScheduleTaskTimes -Force -ErrorAction Stop    
    }
    if($PSBoundParameters.ContainsKey('RemediationScheduleDay') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -RemediationScheduleDay $RemediationScheduleDay -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ReportingAdditionalActionTimeOut') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ReportingAdditionalActionTimeOut $ReportingAdditionalActionTimeOut -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ReportingCriticalFailureTimeOut') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ReportingCriticalFailureTimeOut $ReportingCriticalFailureTimeOut -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ReportingNonCriticalTimeOut') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ReportingNonCriticalTimeOut $ReportingNonCriticalTimeOut -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ScanAvgCPULoadFactor') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ScanAvgCPULoadFactor $ScanAvgCPULoadFactor -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ScanOnlyIfIdleEnabled') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ScanOnlyIfIdleEnabled $ScanOnlyIfIdleEnabled -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ScanParameters') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ScanParameters $ScanParameters -Force -ErrorAction Stop    
    }
    if($PSBoundParameters.ContainsKey('ScanPurgeItemsAfterDelay') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ScanPurgeItemsAfterDelay $ScanPurgeItemsAfterDelay -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ScanScheduleDay') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -ScanScheduleDay $ScanScheduleDay -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SignatureAuGracePeriod') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -SignatureAuGracePeriod $SignatureAuGracePeriod -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SignatureDisableUpdateOnStartupWithoutEngine') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -SignatureDisableUpdateOnStartupWithoutEngine $SignatureDisableUpdateOnStartupWithoutEngine -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SignatureFirstAuGracePeriod') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -SignatureFirstAuGracePeriod $SignatureFirstAuGracePeriod -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SignatureScheduleDay') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -SignatureScheduleDay $SignatureScheduleDay -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SignatureUpdateCatchupInterval') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -SignatureUpdateCatchupInterval $SignatureUpdateCatchupInterval -Force -ErrorAction Stop    
    }
    if($PSBoundParameters.ContainsKey('SignatureUpdateInterval') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -SignatureUpdateInterval $SignatureUpdateInterval -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SubmitSamplesConsent') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -SubmitSamplesConsent $SubmitSamplesConsent -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('UILockdown') -eq $true ){
        $null = Set-MpPreference -CimSession $Script:Cim -UILockdown $UILockdown -Force -ErrorAction Stop
    }

    $status = Get-MpPreference -CimSession $Script:Cim -ErrorAction Stop    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $status
    }
    else{
        Write-Output $status
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}