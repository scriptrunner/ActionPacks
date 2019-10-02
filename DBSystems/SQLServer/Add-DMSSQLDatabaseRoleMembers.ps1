#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Adds members to a specific Role of a specific database

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
    Specifies the name of the database

.Parameter RoleName
    Specifies the name of the role    

.Parameter Members
    Specifies the names of the members to be added to the role, comma separated

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
    [string]$RoleName,
    [Parameter(Mandatory = $true)]   
    [string]$Members,
    [pscredential]$ServerCredential,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    $role = GetSqlDatabase -ServerInstance $instance -Databasename $DBName | Select-Object -ExpandProperty Roles | Where-Object{$_.Name -eq $RoleName}
    foreach($item in $Members.Split(',')){
        $role.AddMember($item)
    }
    $role = GetSqlDatabase -ServerInstance $instance -Databasename $DBName | Select-Object -ExpandProperty Roles | Where-Object{$_.Name -eq $RoleName}

    $Script:result = @()
    $Script:result += $role | Select-Object *
    $Script:result += "Members: $($role.enummembers() -join ',')"
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