#Requires -Version 5.1

<#
.SYNOPSIS
    Starts a volume recovery operation

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

.Parameter VolumeInBackup
    Specifies the id of the volume object that contains the source volume

.Parameter RecoverySkipBadClusterCheck
    Indicates that cmdlet does not perform bad cluster checks

.Parameter RecoveryAsync
    Indicates that the script returns immediately after it starts the backup

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$BackupSetID,   
    [int]$VolumeInBackup = 0,
    [switch]$RecoverySkipBadClusterCheck,
    [switch]$RecoveryAsync,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){            
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                $bSet = Get-WBBackupSet | Where-Object -Property BackupSetID -eq $Using:BackupSetID -ErrorAction Stop;
                Start-WBVolumeRecovery -BackupSet $bSet -VolumeInBackup $bset.Volume[$Using:VolumeInBackup] -SkipBadClusterCheck:$Using:RecoverySkipBadClusterCheck `
                                        -Async:$Using:RecoveryAsync -Force -ErrorAction Stop
            } -ErrorAction Stop
            if($RecoveryAsync -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    Get-WBJob
                }
            }
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                $bSet = Get-WBBackupSet | Where-Object -Property BackupSetID -eq $Using:BackupSetID -ErrorAction Stop;
                Start-WBVolumeRecovery -BackupSet $bSet -VolumeInBackup $bset.Volume[$Using:VolumeInBackup] -SkipBadClusterCheck:$Using:RecoverySkipBadClusterCheck `
                                        -Async:$Using:RecoveryAsync -Force -ErrorAction Stop
            } -ErrorAction Stop
            if($RecoveryAsync -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                    Get-WBJob
                }
            }
        }
    }
    else {
        $Script:bSet = Get-WBBackupSet | Where-Object -Property BackupSetID -eq $BackupSetID -ErrorAction Stop
        $Script:output = Start-WBVolumeRecovery -BackupSet $Script:bSet -VolumeInBackup  $Script:bset.Volume[$VolumeInBackup] -SkipBadClusterCheck:$RecoverySkipBadClusterCheck `
                                    -Async:$RecoveryAsync -Force -ErrorAction Stop
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