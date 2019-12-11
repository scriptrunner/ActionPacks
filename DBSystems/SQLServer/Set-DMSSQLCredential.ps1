#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Sets the properties for the SQL Credential object

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

.Parameter Name
    Specifies the name of the credential

.Parameter Identity
    Specifies the user or account name for the resource SQL Server needs to authenticate to

.Parameter NewPassword
    Specifies the password for the user or account

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$Name,    
    [Parameter(Mandatory = $true)]   
    [string]$Identity,       
    [Parameter(Mandatory = $true)]   
    [securestring]$NewPassword,
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout
       
    [hashtable]$setArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            'Secret' = $NewPassword
                            'InputObject' = $null
                            'Confirm' = $false
                            }   
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Name' = $Name
                            'Confirm' = $false
                            }                                
    $credObject = Get-SqlCredential @getArgs 
    $setArgs['InputObject'] = $credObject
    $result = Set-SqlCredential @setArgs | Select-Object *

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