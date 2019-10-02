#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Enables a database administrator to take the backup of Analysis Service Database to a file

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

.Parameter ASDatabaseName
    Analysis Services Database Name that has to be backed up

.Parameter BackupFile
    The backup file path/name where database will be backed up

.Parameter AllowOverwrite
    Indicates whether the destination files can be overwritten during backup

.Parameter ApplyCompression
    Indicates whether the backup file will be compressed or not

.Parameter BackupRemotePartitions
    Indicates whether remote partitions will be backed up or not

.Parameter FilePassword
    The password to be used with backup file encryption

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,   
    [Parameter(Mandatory = $true)]   
    [string]$ASDatabaseName,
    [Parameter(Mandatory = $true)]   
    [string]$BackupFile,
    [pscredential]$ServerCredential, 
    [switch]$AllowOverwrite,
    [switch]$ApplyCompression,
    [switch]$BackupRemotePartitions,
    [securestring]$FilePassword,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'BackupFile' = $BackupFile
                            'Name' = $ASDatabaseName
                            'AllowOverwrite' = $AllowOverwrite.ToBool()
                            'ApplyCompression' = $ApplyCompression.ToBool()
                            'Confirm' = $false
                            'BackupRemotePartitions' = $BackupRemotePartitions.ToBool()
                            'Server' = $ServerInstance
                            }
    if([System.String]::IsNullOrWhiteSpace($FilePassword) -eq $false){
        $cmdArgs.Add('FilePassword',$FilePassword)
    }
    if($null -ne $ServerCredential){
        $cmdArgs.Add('Credential',$ServerCredential)
    }
   
    $result = Backup-ASDatabase @cmdArgs | Select-Object *    
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