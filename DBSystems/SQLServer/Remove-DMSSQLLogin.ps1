#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Removes Login object from an instance of SQL Server

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

.Parameter LoginName
    Specifies the name of Login object that this cmdlet removes

.Parameter RemoveAssociatedUser
    Indicates that this cmdlet removes the user that are associated with the Login object

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$LoginName,   
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [switch]$RemoveAssociatedUser,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout
    
    if([System.String]::IsNullOrWhiteSpace($LoginName) -eq $false){
        if($LoginName.StartsWith('*') -eq $false){
            $LoginName = '*' + $LoginName
        }
        if($LoginName.EndsWith('*') -eq $false){
            $LoginName += '*'
        }       
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'LoginName' = $LoginName
                            'Wildcard' = $null}
    $sqllogin = Get-SqlLogin @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'InputObject' = $sqllogin
                'RemoveAssociatedUsers' = $RemoveAssociatedUser
                'Confirm' = $false
                'Force' = $true
                }       
    Remove-SqlLogin @cmdArgs
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Login $($LoginName) successfully removed"
    }
    else{
        Write-Output "Login $($LoginName) successfully removed"
    }
}
catch{
    throw
}
finally{
}