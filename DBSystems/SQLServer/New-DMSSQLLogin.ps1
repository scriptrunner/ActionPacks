#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Creates a Login object in an instance of SQL Server

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

.Parameter LoginType
    Specifies the type of the Login object

.Parameter LoginCredential
    Specifies a PSCredential object that allows the Login object to provide name and password without a prompt

.Parameter DefaultDatabase
    Specify the default database for the Login object

.Parameter Enable
    Indicates that the Login object is enabled. By default, Login objects are disabled

.Parameter EnforcePasswordExpiration
    Indicates that the password expiration policy is enforced for the Login object
        
.Parameter EnforcePasswordPolicy
    Indicates that the password policy is enforced for the Login object

.Parameter MustChangePasswordAtNextLogin
    Indicates that the user must change the password at the next login

.Parameter GrantConnectSql
    Indicates that the Login object is not denied permissions to connect to the database engine. 
    By default, Login objects are denied permissions to connect to the database engine

.Parameter AsymmetricKey
    Specify the name of the asymmetric key for the Login object

.Parameter Certificate
    Specify the name of the certificate for the Login object

.Parameter CredentialName
    Specify the name of the credential for the Login object

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$LoginCredential,
    [Parameter(Mandatory = $true)]   
    [ValidateSet('WindowsUser', 'WindowsGroup', 'SqlLogin', 'Certificate', 'AsymmetricKey')]
    [string]$LoginType = "SqlLogin",
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$DefaultDatabase,
    [switch]$Enable,
    [switch]$EnforcePasswordExpiration,
    [switch]$EnforcePasswordPolicy,
    [switch]$MustChangePasswordAtNextLogin,
    [switch]$GrantConnectSql,
    [string]$AsymmetricKey,
    [string]$Certificate,
    [string]$CredentialName,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    [string[]]$Properties = @('Name','Status','LoginType','Language','IsLocked','IsDisabled','IsPasswordExpired','MustChangePassword','PasswordExpirationEnabled','HasAccess','State')
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'LoginType' = $LoginType
                            'InputObject' = $instance
                            'Enable' = $Enable.ToBool()
                            "LoginPSCredential" = $LoginCredential
                            'GrantConnectSql' = $GrantConnectSql.ToBool()
                            }
    if($LoginType -eq "SqlLogin"){
        $cmdArgs.Add("EnforcePasswordExpiration",$EnforcePasswordExpiration.ToBool())
        $cmdArgs.Add("EnforcePasswordPolicy",$EnforcePasswordPolicy.ToBool())
        $cmdArgs.Add("MustChangePasswordAtNextLogin",$MustChangePasswordAtNextLogin.ToBool())
    } 
    if([System.String]::IsNullOrWhiteSpace($DefaultDatabase) -eq $false){        
        $cmdArgs.Add("DefaultDatabase",$DefaultDatabase)
    }
    if([System.String]::IsNullOrWhiteSpace($AsymmetricKey) -eq $false){        
        $cmdArgs.Add("AsymmetricKey",$AsymmetricKey)
    }
    if([System.String]::IsNullOrWhiteSpace($Certificate) -eq $false){        
        $cmdArgs.Add("Certificate",$Certificate)
    }
    if([System.String]::IsNullOrWhiteSpace($CredentialName) -eq $false){        
        $cmdArgs.Add("CredentialName",$CredentialName)
    }
       
    $result = Add-SqlLogin @cmdArgs | Select-Object $Properties
    
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