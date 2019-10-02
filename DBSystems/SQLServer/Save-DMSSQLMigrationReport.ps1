#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Generates In-Memory OLTP Migration Checklist

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

.Parameter DatabaseName
    The name of the databased for which the report is going to be generated

.Parameter FolderPath
    A path to a folder where the report files will be saved to

.Parameter MigrationType
    The type of the migration. Currently, only OLTP is supported

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,    
    [pscredential]$ServerCredential,
    [string]$FolderPath,
    [ValidateSet('OLTP')]
    [string]$MigrationType = 'OLTP',
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    $dbInstance = GetSqlDatabase -DatabaseName $DatabaseName -ServerInstance $instance
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $dbInstance
                            'MigrationType' = $MigrationType
                            }                                     
    if([System.String]::IsNullOrWhiteSpace($FolderPath) -eq $false){
        $cmdArgs.Add('FolderPath',$FolderPath)
    }
    $result = Save-SqlMigrationReport @cmdArgs
    
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