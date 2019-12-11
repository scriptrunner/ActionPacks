#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Creates a column encryption key object in the database

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
    Specifies the SQL database object for runs the operation

.Parameter ColumnMasterKeyName
    Specifies the name of the column master key that was used to produce the specified encrypted value of the column encryption key, 
    or the name the column master key that is used to produce the new encrypted value

.Parameter KeyName
    Specifies the name of the column encryption key object to be created

.Parameter EncryptedValue
    Specifies a string that this cmdlet uses to encrypt the column master key

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,    
    [Parameter(Mandatory = $true)]   
    [string]$ColumnMasterKeyName ,    
    [Parameter(Mandatory = $true)]  
    [string]$KeyName,
    [pscredential]$ServerCredential,
    [string]$EncryptedValue,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    $dbInstance = GetSqlDatabase -DatabaseName $DatabaseName -ServerInstance $instance
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $dbInstance
                            'ColumnMasterKeyName' = $ColumnMasterKeyName
                            'Name' = $KeyName
                            }
    if([System.String]::IsNullOrWhiteSpace($EncryptedValue) -ne $true){
        $cmdArgs.Add("EncryptedValue",$EncryptedValue)
    }

    $result = New-SqlColumnEncryptionKey @cmdArgs | Select-Object *
    
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