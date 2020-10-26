#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Restores a database from a backup or transaction log records

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
    Specifies the name of the database to restore

.Parameter BackupFile
    Specifies the location and file name of the backup

.Parameter RestoreAction
    Specifies the type of backup operation to perform

.Parameter Checksum
    Indicates that a checksum value is calculated during the restore operation

.Parameter ClearSuspectPageTable
    Indicates that the suspect page table is deleted after the restore operation

.Parameter ContinueAfterError
    Indicates that the operation continues when a checksum error occurs. 
    If not set, the operation will fail after a checksum error

.Parameter DatabaseFile
    Specifies the database files targeted by the restore operation, comma separated. 
    This is only used when the RestoreAction parameter is set to File

.Parameter DatabaseFileGroup
    Specifies the database file groups targeted by the restore operation, comma separated. 
    This is only used when the RestoreAction parameter is set to File

.Parameter KeepReplication
    Indicates that the replication configuration is preserved

.Parameter NoRecovery
    Indicates that the database is restored into the restoring state

.Parameter ReplaceDatabase
    Indicates that a new image of the database is created. This overwrites any existing database with the same name. 
    If not set, the restore operation will fail when a database with that name already exists on the server.

.Parameter ToPointInTime
    Specifies the endpoint for database log restoration. This only applies when RestoreAction is set to Log

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DBName,
    [Parameter(Mandatory = $true)]   
    [string]$BackupFile,
    [pscredential]$ServerCredential,
    [ValidateSet('Database', 'Files', 'Log',  'OnlinePage', 'OnlineFiles')]
    [string]$RestoreAction = "Database",
    [switch]$CheckSum,
    [switch]$ClearSuspectPageTable,
    [switch]$ContinueAfterError,
    [string]$DatabaseFile,
    [string]$DatabaseFileGroup,
    [switch]$KeepReplication,
    [switch]$NoRecovery,
    [switch]$ReplaceDatabase,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$ToPointInTime,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{    
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Database' = $DBName
                            'Confirm' = $false
                            'RestoreAction' = $RestoreAction
                            'CheckSum' = $CheckSum
                            'ClearSuspectPageTable' = $ClearSuspectPageTable
                            'ContinueAfterError' = $ContinueAfterError
                            'BackupFile' = $BackupFile
                            'KeepReplication' = $KeepReplication
                            'ReplaceDatabase' = $ReplaceDatabase
                            'NoRecovery' = $NoRecovery
                            'PassThru' = $true
                            }

    if($RestoreAction -eq 'Files'){
        if([System.String]::IsNullOrWhiteSpace($DatabaseFile) -eq $false){
            $cmdArgs.Add('DatabaseFile',$DatabaseFile.Split(','))
        }
        elseif([System.String]::IsNullOrWhiteSpace($DatabaseFileGroup) -eq $false){
            $cmdArgs.Add('DatabaseFileGroup',$DatabaseFileGroup.Split(','))
        }
    }
    elseif($RestoreAction -eq 'Log'){
        if($null -ne $ToPointInTime){
            $cmdArgs.Add('ToPointInTime',$ToPointInTime)
        }
    }

    $result = Restore-SqlDatabase @cmdArgs | Select-Object *    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}