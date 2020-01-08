#Requires -Version 5.1

<#
.SYNOPSIS
    Sets the backup policy for scheduled backups

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Server/Backup

.Parameter BackupTarget
    Specifies the drive letter of the volume that stores backups 

.Parameter Files
    Specifies an list of files to add to the policy object, separated by a comma

.Parameter ExcludeFiles
    Specifies an list of files that the backup excludes from the backup, separated by a comma

.Parameter DrivesToBackup
    Specifies the drive letters to add to the policy object, separated by a comma

.Parameter ScheduleTimes
    Specifies the times of day to create a backup. Time values are formatted as HH:MM and separated by a comma

.Parameter AllowDeleteOldBackups
    Indicates whether new backups can overwrite older backups

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(        
    [Parameter(Mandatory = $true)]
    [string]$BackupTarget,
    [Parameter(Mandatory = $true)]
    [string]$ScheduleTimes,
    [string]$Files,
    [string]$ExcludeFiles,
    [string]$DrivesToBackup,
    [switch]$AllowDeleteOldBackups,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    [string[]]$Script:Properties = @("Schedule","BackupTargets","VolumesToBackup","FilesSpecsToBackup","FilesSpecsToExclude")
    $Script:output
    [string[]]$Script:Schedules = $ScheduleTimes.Split(",")
    [string[]]$Script:Files2Save = $Files.Split(",")
    [string[]]$Script:Files2Exclude = $ExcludeFiles.Split(",")
    [string[]]$Script:Drives2Backup = $DrivesToBackup.Split(",")
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
       if($null -eq $AccessAccount){
             $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                $policy = New-WBPolicy;
                $target = New-WBBackupTarget -VolumePath $Using:BackupTarget;
                $null = Add-WBBackupTarget -Force -Policy $policy -Target $target -ErrorAction Stop;
                if(($null -ne $Using:Files2Save) -and ($Using:Files2Save.Length -gt 0)){
                    foreach($file in $Using:Files2Save){
                        $spec = New-WBFileSpec -FileSpec $file
                        $null = Add-WBFileSpec -Policy $policy -FileSpec $spec -ErrorAction Stop
                    }
                };
                if(($null -ne $Using:Files2Exclude) -and ($Using:Files2Exclude.Length -gt 0)){
                    foreach($exclu in $Using:Files2Exclude){
                        $exAdd = New-WBFileSpec -FileSpec $exclu -Exclude
                        $null = Add-WBFileSpec -Policy $policy -FileSpec $exAdd -ErrorAction Stop
                    }
                };
                if(($null -ne $Using:Drives2Backup) -and ($Using:Drives2Backup.Length -gt 0)){
                    foreach($volu in $Using:Drives2Backup){
                        $volAdd = Get-WBVolume -VolumePath $volu
                        $null = Add-WBVolume -Policy $policy -Volume $volAdd -ErrorAction Stop
                    }
                };
                if(($null -ne $Using:Schedules) -and ($Using:Schedules.Length -gt 0)){
                    $null = Set-WBSchedule -Policy $policy -Schedule $Using:Schedules -ErrorAction Stop
                };
                $null = Set-WBPolicy -Policy $policy -AllowDeleteOldBackups:$AllowDeleteOldBackups -Force -Confirm:$false -ErrorAction Stop;
                Get-WBPolicy | Select-Object $Script:Properties
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                $policy = New-WBPolicy;
                $target = New-WBBackupTarget -VolumePath $Using:BackupTarget;
                $null = Add-WBBackupTarget -Force -Policy $policy -Target $target -ErrorAction Stop;
                if(($null -ne $Using:Files2Save) -and ($Using:Files2Save.Length -gt 0)){
                    foreach($file in $Using:Files2Save){
                        $spec = New-WBFileSpec -FileSpec $file
                        $null = Add-WBFileSpec -Policy $policy -FileSpec $spec -ErrorAction Stop
                    }
                };
                if(($null -ne $Using:Files2Exclude) -and ($Using:Files2Exclude.Length -gt 0)){
                    foreach($exclu in $Using:Files2Exclude){
                        $exAdd = New-WBFileSpec -FileSpec $exclu -Exclude
                        $null = Add-WBFileSpec -Policy $policy -FileSpec $exAdd -ErrorAction Stop
                    }
                };
                if(($null -ne $Using:Drives2Backup) -and ($Using:Drives2Backup.Length -gt 0)){
                    foreach($volu in $Using:Drives2Backup){
                        $volAdd = Get-WBVolume -VolumePath $volu
                        $null = Add-WBVolume -Policy $policy -Volume $volAdd -ErrorAction Stop
                    }
                };
                if(($null -ne $Using:Schedules) -and ($Using:Schedules.Length -gt 0)){
                    $null = Set-WBSchedule -Policy $policy -Schedule $Using:Schedules -ErrorAction Stop
                };
                $null = Set-WBPolicy -Policy $policy -AllowDeleteOldBackups:$AllowDeleteOldBackups -Force -Confirm:$false -ErrorAction Stop;
                Get-WBPolicy | Select-Object $Script:Properties
            } -ErrorAction Stop
        }
    }
    else {
        $policy = New-WBPolicy
        $target = New-WBBackupTarget -VolumePath $BackupTarget
        $null = Add-WBBackupTarget -Force -Policy $policy -Target $target -ErrorAction Stop
        if(($null -ne $Script:Files2Save) -and ($Script:Files2Save.Length -gt 0)){
            foreach($file in $Script:Files2Save){
                $spec = New-WBFileSpec -FileSpec $file
                $null = Add-WBFileSpec -Policy $policy -FileSpec $spec -ErrorAction Stop
            }
        }
        if(($null -ne $Script:Files2Exclude) -and ($Script:Files2Exclude.Length -gt 0)){
            foreach($exclu in $Script:Files2Exclude){
                $exAdd = New-WBFileSpec -FileSpec $exclu -Exclude
                $null = Add-WBFileSpec -Policy $policy -FileSpec $exAdd -ErrorAction Stop
            }
        }
        if(($null -ne $Script:Drives2Backup) -and ($Script:Drives2Backup.Length -gt 0)){
            foreach($volu in $Script:Drives2Backup){
                $volAdd = Get-WBVolume -VolumePath $volu
                $null = Add-WBVolume -Policy $policy -Volume $volAdd -ErrorAction Stop
            }
        }
        if(($null -ne $Script:Schedules) -and ($Script:Schedules.Length -gt 0)){
            $null = Set-WBSchedule -Policy $policy -Schedule $Script:Schedules -ErrorAction Stop
        }
        $null = Set-WBPolicy -Policy $policy -AllowDeleteOldBackups:$AllowDeleteOldBackups -Force -Confirm:$false -ErrorAction Stop
        $Script:output = Get-WBPolicy -ErrorAction Stop | Select-Object $Script:Properties
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}