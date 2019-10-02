#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Configures or modifies backup retention and storage settings

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

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SQLServer
 
.Parameter ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.Parameter ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.
    
.Parameter DatabaseName
    Specifies the name of the database that this cmdlet gets the SQL Smart Admin object

.Parameter BackupEnabled
    Indicates that this cmdlet enables SQL Server Managed Backup to Windows Azure

.Parameter BackupRetentionPeriodInDays
    Specifies the number of days the backup files should be retained

.Parameter MasterSwitch
    Indicates that this cmdlet pauses or restarts all services under Smart Admin including SQL Server Managed Backup to Windows Azure

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$DatabaseName,
    [bool]$BackupEnabled,
    [int]$BackupRetentionPeriodInDays,
    [bool]$MasterSwitch,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Confirm' = $false
                            }    
    [hashtable]$setArgs = @{'ErrorAction' = 'Stop'
                            'BackupEnabled' = $BackupEnabled
                            'MasterSwitch' = $MasterSwitch
                            'Confirm' = $false
                            }
    if([System.String]::IsNullOrWhiteSpace($DatabaseName) -eq $false){
        $getArgs.Add('DatabaseName',$DatabaseName)
    }
    if($BackupRetentionPeriodInDays -gt 0){
        $setArgs.Add('BackupRetentionPeriodInDays',$BackupRetentionPeriodInDays)
    }

    $result = Get-SqlSmartAdmin @getArgs | Set-SqlSmartAdmin @setArgs | Select-Object *    
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