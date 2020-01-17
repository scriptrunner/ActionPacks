#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Sets or resets the maximum number of error log files before they are recycled

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

.Parameter MaxLogCount
    Indicates that the cmdlet sorts the collection of error logs by the log date in ascending order

.Parameter After
    Specifies that this cmdlet only gets error logs generated after the given time

.Parameter Before
    Specifies that this cmdlet only gets error logs generated before the given time
        
.Parameter Since
    Specifies an abbreviation for the Timespan parameter

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [ValidateRange(6,99)]
    [int]$MaxLogCount,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    [string[]]$Properties = @('Date','Source','Text','ServerInstance')
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'MaxLogCount' = $MaxLogCount
                            }     
    $null = Set-SqlErrorLog @cmdArgs                            
    $result = Get-SqlErrorLog -InputObject $instance -ErrorAction Stop | Select-Object $Properties
    
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