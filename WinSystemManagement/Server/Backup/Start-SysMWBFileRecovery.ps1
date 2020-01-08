#Requires -Version 5.1

<#
.SYNOPSIS
    Starts a file recovery operation

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

.Parameter BackupSetID
    Specifies the id of an backup set 

.Parameter TargetPath
    Specifies the location where recovered files reside after the recovery. 
    If you do not specify this parameter, the backup operation recovers files to their original locations

.Parameter RecoveryOption
    Specifies an object that contains file recovery options. 
    The options specify the action to take when a file that you recover already exists in the same location

.Parameter RecoveryAsync
    Indicates that the script returns immediately after it starts the backup

.Parameter RecoveryRecursive
    Indicates that Windows Server Backup recovers the files from the folders that you specify along with files in folders that are subordinate to those folders

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$BackupSetID,   
    [string]$TargetPath,
    [ValidateSet("Default", "SkipIfExists", "CreateCopyIfExists", "OverwriteIfExists")]
    [string]$RecoveryOption = "Default",
    [switch]$RecoveryAsync,
    [switch]$RecoveryRecursive,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            if([System.String]::IsNullOrWhiteSpace($TargetPath) -eq $false){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    $bSet = Get-WBBackupSet | Where-Object -Property BackupSetID -eq $Using:BackupSetID -ErrorAction Stop;
                    $target = Get-WBBackupVolumeBrowsePath -BackupSet $bset -VolumeInBackup $bset.Volume[0];
                    Start-WBFileRecovery -BackupSet $bSet -SourcePath $target -Option $Using:RecoveryOption -Async:$Using:RecoveryAsync -Recursive:$Using:RecoveryRecursive -Force -ErrorAction Stop
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    $bSet = Get-WBBackupSet | Where-Object -Property BackupSetID -eq $Using:BackupSetID -ErrorAction Stop;
                    $target = Get-WBBackupVolumeBrowsePath -BackupSet $bset -VolumeInBackup $bset.Volume[0];
                    Start-WBFileRecovery -BackupSet $bSet -SourcePath $target -TargetPath $Using:TargetPath -Option $Using:RecoveryOption -Async:$Using:RecoveryAsync -Recursive:$Using:RecoveryRecursive -Force -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($RecoveryAsync -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    Get-WBJob
                }
            }
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($TargetPath) -eq $false){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                    $bSet = Get-WBBackupSet | Where-Object -Property BackupSetID -eq $Using:BackupSetID -ErrorAction Stop;
                    $target = Get-WBBackupVolumeBrowsePath -BackupSet $bset -VolumeInBackup $bset.Volume[0];
                    Start-WBFileRecovery -BackupSet $bSet -SourcePath $target -Option $Using:RecoveryOption -Async:$Using:RecoveryAsync -Recursive:$Using:RecoveryRecursive -Force -ErrorAction Stop
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                    $bSet = Get-WBBackupSet | Where-Object -Property BackupSetID -eq $Using:BackupSetID -ErrorAction Stop;
                    $target = Get-WBBackupVolumeBrowsePath -BackupSet $bset -VolumeInBackup $bset.Volume[0];
                    Start-WBFileRecovery -BackupSet $bSet -SourcePath $target -TargetPath $Using:TargetPath -Option $Using:RecoveryOption -Async:$Using:RecoveryAsync -Recursive:$Using:RecoveryRecursive -Force -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($RecoveryAsync -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                    Get-WBJob
                }
            }
        }
    }
    else {
        $Script:bSet = Get-WBBackupSet | Where-Object -Property BackupSetID -eq $BackupSetID -ErrorAction Stop
        $Script:target = Get-WBBackupVolumeBrowsePath -BackupSet $bset -VolumeInBackup $bset.Volume[0] -ErrorAction Stop
        if([System.String]::IsNullOrWhiteSpace($TargetPath) -eq $false){
            $Script:output = Start-WBFileRecovery -BackupSet $Script:bSet -SourcePath $Script:target -Option $RecoveryOption -Async:$RecoveryAsync -Recursive:$RecoveryRecursive -Force -ErrorAction Stop
        }
        else {
            $Script:output = Start-WBFileRecovery -BackupSet $Script:bSet -SourcePath $Script:target -TargetPath $TargetPath -Option $RecoveryOption -Async:$RecoveryAsync -Recursive:$RecoveryRecursive -Force -ErrorAction Stop
        }
        if($RecoveryAsync -eq $true){
            $Script:output = Get-WBJob -ErrorAction Stop
        }
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