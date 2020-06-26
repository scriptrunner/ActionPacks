#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Gets a SQL database object for each database that is present in the target instance of SQL Server

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
    Specifies the name of the database that this cmdlet gets the SQL database object

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
    [string]$DBName,
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
                            'Confirm' = $false
                            }
    if([System.String]::IsNullOrWhiteSpace($DBName) -eq $false){
        $cmdArgs.Add("Name",$DBName)
    }
    
    $result = Get-SqlDatabase @cmdArgs | Select-Object $Properties
    
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