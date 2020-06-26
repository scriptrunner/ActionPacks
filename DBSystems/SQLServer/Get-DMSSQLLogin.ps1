#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Returns Login objects in an instance of SQL Server

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
    Specifies the name of Login object that this cmdlet gets

.Parameter OnlyDisabled
    Indicates that this cmdlet gets only disabled Login objects

.Parameter OnlyHasAccess
    Indicates that this cmdlet gets only Login objects that have access to the instance of SQL Server
        
.Parameter OnlyLocked
    Indicates that this cmdlet gets only locked Login objects

.Parameter OnlyPasswordExpired
    Indicates that this cmdlet gets only Login objects that have expired passwords

.Parameter LoginType
    Specifies the type of the Login objects that this cmdlet gets

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
    [string]$LoginName,
    [switch]$OnlyDisabled,
    [switch]$OnlyHasAccess,
    [switch]$OnlyLocked,
    [switch]$OnlyPasswordExpired,
    [ValidateSet('All','WindowsUser', 'WindowsGroup', 'SqlLogin', 'Certificate', 'AsymmetricKey', 'ExternalUser', 'ExternalGroup')]
    [string]$LoginType = "All",
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','Name','Status','LoginType','Language','IsLocked','IsDisabled','IsPasswordExpired','MustChangePassword','PasswordExpirationEnabled','HasAccess','State')]
    [string[]]$Properties = @('Name','Status','LoginType','Language','IsLocked','IsDisabled','IsPasswordExpired','MustChangePassword','PasswordExpirationEnabled','HasAccess','State')
)

Import-Module SQLServer

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Disabled' = $OnlyDisabled.ToBool()
                            'Locked' = $OnlyLocked.ToBool()
                            'PasswordExpired' = $OnlyPasswordExpired.ToBool()
                            'HasAccess' = $OnlyHasAccess.ToBool()
                            }
    if([System.String]::IsNullOrWhiteSpace($LoginName) -eq $false){
        if($LoginName.StartsWith('*') -eq $false){
            $LoginName = '*' + $LoginName
        }
        if($LoginName.EndsWith('*') -eq $false){
            $LoginName += '*'
        }
        $cmdArgs.Add("LoginName",$LoginName)
        $cmdArgs.Add("Wildcard",$null)
    }
    if($LoginType -ne "All"){
        $cmdArgs.Add("LoginType",$LoginType)
    }    
    try{      
        $Script:result = Get-SqlLogin @cmdArgs | Select-Object $Properties
    }
    catch
    {
        if($_.Exception.GetType().Name -eq "SqlPowerShellObjectNotFoundException"){
            $Script:result = "No logins found"
        }
    }
    
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