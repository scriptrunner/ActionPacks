#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Generates a report with the roles and there mmembers from the SQL database object

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
    Requires the library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/DBSystems/_REPORTS_
 
.Parameter ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.Parameter ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.Parameter DBName
    Specifies the name of the database that gets the roles

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
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout
    $roles = GetSqlDatabase -DatabaseName $DBName -ServerInstance $instance | Select-Object -ExpandProperty Roles

    $Script:result = @()
    foreach($item in $roles){
        $Script:result += [PSCustomObject]@{
            'Object type' = 'Role';
            'Name' = $item.Name
        }
        foreach($member in $item.enummembers()){
            [PSCustomObject]@{
                'Object type' = 'Member';
                'Name' = $member
            }
        }
    }    

    ConvertTo-ResultHtml -Result $Script:result
}
catch{
    throw
}
finally{
}