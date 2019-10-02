#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Backs up SQL Server database objects

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module SQLServer
    Requires the library script DMSSqlServer.ps1
    
.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SQLServer
 
.Parameter ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.Parameter ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.Parameter DBName
    Specifies the name of the database to back up

.Parameter BackupAction
    Specifies the type of backup operation to perform

.Parameter BackupFile
    Specifies the location and file name of the backup

.Parameter BackupContainer
    Specifies the folder or location where the cmdlet stores backups

.Parameter BackupSetDescription
    Specifies the description of the backup set

.Parameter BackupSetName
    Specifies the name of the backup set

.Parameter BlockSize
    Specifies the physical block size for the backup

.Parameter Checksum
    Indicates that a checksum value is calculated during the backup operation

.Parameter CompressionOption
    Specifies the compression options for the backup operation

.Parameter CopyOnly
    Indicates that the backup is a copy-only backup

.Parameter ContinueAfterError
    Indicates that the operation continues when a checksum error occurs

.Parameter DatabaseFile
    Specifies one or more database files to back up, comma separated. 
    This parameter is only used when BackupAction is set to Files

.Parameter DatabaseFileGroup
    Specifies the database file groups targeted by the backup operation, comma separated. 
    This parameter is only used when BackupAction is set to Files

.Parameter Incremental
    Indicates that a differential backup is performed

.Parameter LogTruncationType
    Specifies the truncation behavior for log backups

.Parameter NoRecovery
    Indicates that the tail end of the log is not backed up

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DBName,
    [pscredential]$ServerCredential,    
    [ValidateSet('Database', 'Files', 'Log')]
    [string]$BackupAction = "Database",
    [string]$BackupFile,
    [string]$BackupContainer,
    [string]$BackupSetName,
    [string]$BackupSetDescription,     
    [ValidateSet('512', '1024', '2048', '4096', '8192', '16384','32768','65536')]
    [string]$BlockSize = "512",
    [switch]$CheckSum,
    [switch]$ContinueAfterError,
    [switch]$CopyOnly,
    [ValidateSet('Default','On','Off')]
    [string]$CompressionOption = "Default",
    [string]$DatabaseFile,
    [string]$DatabaseFileGroup,
    [switch]$Incremental,
    [ValidateSet('TruncateOnly','Truncate','NoTruncate')]
    [string]$LogTruncationType = "Truncate",
    [switch]$NoRecovery,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Database' = $DBName
                            'Confirm' = $false
                            'BackupAction' = $BackupAction
                            'BlockSize' = [int]$BlockSize
                            'CheckSum' = $CheckSum
                            'CompressionOption' = $CompressionOption
                            'ContinueAfterError' = $ContinueAfterError
                            'CopyOnly' = $CopyOnly
                            'Incremental' = $Incremental
                            'LogTruncationType' = $LogTruncationType
                            'NoRecovery' = $NoRecovery
                            'PassThru' = $true
                            }
    if([System.String]::IsNullOrWhiteSpace($BackupFile) -eq $false){
        $cmdArgs.Add('BackupFile',$BackupFile)
    }
    elseif([System.String]::IsNullOrWhiteSpace($BackupContainer) -eq $false){
        $cmdArgs.Add('BackupContainer',$BackupContainer)
    }
    if([System.String]::IsNullOrWhiteSpace($BackupSetName) -eq $false){
        $cmdArgs.Add('BackupSetName',$BackupSetName)
    }
    if([System.String]::IsNullOrWhiteSpace($BackupSetDescription) -eq $false){
        $cmdArgs.Add('BackupSetDescription',$BackupSetDescription)
    }
    if($BackupAction -eq 'Files'){
        if([System.String]::IsNullOrWhiteSpace($DatabaseFile) -eq $false){
            $cmdArgs.Add('DatabaseFile',$DatabaseFile.Split(','))
        }
        elseif([System.String]::IsNullOrWhiteSpace($DatabaseFileGroup) -eq $false){
            $cmdArgs.Add('DatabaseFileGroup',$DatabaseFileGroup.Split(','))
        }
    }
   
    $Script:result = Backup-SqlDatabase @cmdArgs | Select-Object *    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
    }
    else{
        Write-Output $Script:result
    }
}
catch{
    throw
}
finally{
}