#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Removes members from a specific Role of the SQL Instance object

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

.Parameter RoleName
    Specifies the name of the role    

.Parameter Members
    Specifies the names of the members to be removed from the role, comma separated

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,   
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
   
    $role = $instance | Select-Object -ExpandProperty Roles | Where-Object{$_.Name -eq $RoleName}
    foreach($item in $Members.Split(',')){
        $role.DropMember($item)
    }
    $role = $instance | Select-Object -ExpandProperty Roles | Where-Object{$_.Name -eq $RoleName}

    $result = @()
    $result += $role | Select-Object *
    $result += "Members: $($role.EnumMemberNames() -join ',')"
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