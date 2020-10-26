#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Gets backup information about databases and returns SMO BackupSet objects for each Backup record found based on the parameters specified to this cmdlet

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

.Parameter BackupType
    The type of backup to filter on. If not specified then gets all backup types

.Parameter DBName
    The names of the databases whose backup records are to be retrieved, comma separated

.Parameter EndTime
    The time before which all backup records to be retrieved should have completed

.Parameter IgnoreProviderContext
    Indicates that this cmdlet does not use the current context to override the values of the ServerInstance, DatabaseName parameters

.Parameter IncludeSnapshotBackups
    This switch will make the cmdlet obtain records for snapshot backups as well

.Parameter Since
    Specifies an abbreviation that you can instead of the StartTime parameter

.Parameter StartTime
    Gets the backup records which started after this specified time

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Status. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [ValidateSet('Database', 'Differential', 'Incremental', 'Log', 'FileOrFileGroup', 'FileOrFileGroupDifferential')]
    [string]$BackupType,
    [string]$DBName,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndTime,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartTime,
    [switch]$IgnoreProviderContext,
    [switch]$IncludeSnapshotBackups,
    [switch]$SuppressProviderContextWarning,
    [ValidateSet('Midnight', 'Yesterday', 'LastWeek', 'LastMonth')]
    [string]$Since,
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','Name','Status','Size','SpaceAvailable','Owner','LastBackupDate','LastLogBackupDate','IsUpdateable','DefaultFileGroup','AutoShrink','ActiveConnections')]
    [string[]]$Properties = @('Name','Status','Size','SpaceAvailable','Owner','LastBackupDate','LastLogBackupDate','IsUpdateable','DefaultFileGroup','AutoShrink','ActiveConnections')
)

Import-Module SQLServer

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'IgnoreProviderContext' = $IgnoreProviderContext
                            'IncludeSnapshotBackups' = $IncludeSnapshotBackups
                            'SuppressProviderContextWarning' = $SuppressProviderContextWarning
                            }
    if([System.String]::IsNullOrWhiteSpace($DBName) -eq $false){
        $cmdArgs.Add("DatabaseName",$DBName)
    }
    if([System.String]::IsNullOrWhiteSpace($BackupType) -eq $false){
        $cmdArgs.Add("BackupType",$BackupType)
    }
    if($null -ne $EndTime){
        $cmdArgs.Add('EndTime',$EndTime)
    }
    if($null -ne $StartTime){
        $cmdArgs.Add('StartTime',$StartTime)
    }
    if(($null -eq $StartTime) -and ([System.String]::IsNullOrWhiteSpace($Since) -eq $false)){
        $cmdArgs.Add("Since",$Since)
    }
    
    $result = Get-SqlBackupHistory @cmdArgs | Select-Object $Properties
    
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