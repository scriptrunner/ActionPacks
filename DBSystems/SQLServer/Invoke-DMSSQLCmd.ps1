#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Runs a script containing statements supported by the SQL Server SQLCMD utility

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

.Parameter Query
    Specifies one or more queries that this cmdlet runs. The queries can be Transact-SQL or XQuery statements, or sqlcmd commands    

.Parameter File
    Specifies a file to be used as the query input to this cmdlet

.Parameter QueryTimeout
    Specifies the number of seconds before the queries time out

.Parameter AbortOnError
    Indicates that this cmdlet stops the SQL Server command and returns an error level 
    to the Windows PowerShell ERRORLEVEL variable if this cmdlet encounters an error

.Parameter DatabaseName
    Specifies the name of a database

.Parameter EncryptConnection
    Indicates that this cmdlet uses Secure Sockets Layer (SSL) encryption for the connection to the instance of the Database Engine specified in the ServerInstance parameter
        
.Parameter DisableVariables
    Indicates that this cmdlet ignores sqlcmd scripting variables

.Parameter DisableCommands
    Indicates that this cmdlet turns off some sqlcmd features that might compromise security when run in batch files

.Parameter DedicatedAdministratorConnection
    Indicates that this cmdlet uses a Dedicated Administrator Connection (DAC) to connect to an instance of the Database Engine

.Parameter OutputSqlErrors
    Indicates that this cmdlet displays error messages in the Invoke-Sqlcmd output

.Parameter IncludeSqlUserErrors
    Indicates that this cmdlet returns SQL user script errors that are otherwise ignored by default

.Parameter ErrorLevel
    Specifies that this cmdlet display only error messages whose severity level is equal to or higher than the value specified

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Query')]   
    [Parameter(Mandatory = $true, ParameterSetName = 'File')]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true,ParameterSetName = "Query")]   
    [Parameter(Mandatory = $true,ParameterSetName = "File")]   
    [string]$DatabaseName,   
    [Parameter(Mandatory = $true, ParameterSetName = 'Query')]   
    [string]$Query,
    [Parameter(Mandatory = $true, ParameterSetName = 'File')]   
    [string]$File,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]         
    [ValidateRange(1,65535)]
    [int]$QueryTimeout ,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [pscredential]$ServerCredential,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$AbortOnError,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$EncryptConnection,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$DisableCommands,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$DisableVariables,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$DedicatedAdministratorConnection,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [bool]$OutputSqlErrors,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [switch]$IncludeSqlUserErrors,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [ValidateRange(1,24)]
    [int]$ErrorLevel ,
    [Parameter(ParameterSetName = 'Query')]   
    [Parameter(ParameterSetName = 'File')]   
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ServerInstance' = $instance
                            'Database' = $DatabaseName
                            'DisableCommands' = $DisableCommands.ToBool()
                            'DisableVariables' = $DisableVariables.ToBool()                            
                            'EncryptConnection' = $EncryptConnection.ToBool()
                            'AbortOnError' = $AbortOnError.ToBool()
                            'OutputSqlErrors' = $OutputSqlErrors
                            'DedicatedAdministratorConnection' = $DedicatedAdministratorConnection.ToBool()
                            'IncludeSqlUserErrors' = $IncludeSqlUserErrors.ToBool()
                            }
    if($ErrorLevel -gt 0){        
        $cmdArgs.Add("ErrorLevel",$ErrorLevel)
    }
    if($QueryTimeout -gt 0){        
        $cmdArgs.Add("QueryTimeout",$QueryTimeout)
    }
    if($PSCmdlet.ParameterSetName -eq "Query"){
        $cmdArgs.Add("Query",$Query)
    }    
    else{      
        $cmdArgs.Add("InputFile",$File)
    }
    
    $result = Invoke-Sqlcmd @cmdArgs
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