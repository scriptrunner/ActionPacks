#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Restores a specified Analysis Service database from a backup file

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

.Parameter ASDatabaseName
    Analysis Services Database Name that has to be restored

.Parameter RestoreFile
    Restores a specified Analysis Service database from a backup file

.Parameter AllowOverwrite
    Indicates whether the destination files can be overwritten during restore

.Parameter Security
    Represents security settings for the restore operation

.Parameter FilePassword
    The password from the backup file encryption

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,   
    [Parameter(Mandatory = $true)]   
    [string]$ASDatabaseName,
    [Parameter(Mandatory = $true)]   
    [string]$RestoreFile,
    [pscredential]$ServerCredential, 
    [switch]$AllowOverwrite,
    [ValidateSet('CopyAll', 'SkipMembership', 'IgnoreSecurity')]
    [string]$Security,
    [securestring]$FilePassword,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'RestoreFile' = $RestoreFile
                            'Name' = $ASDatabaseName
                            'AllowOverwrite' = $AllowOverwrite.ToBool()
                            'Confirm' = $false
                            'Server' = $ServerInstance
                            }
    if([System.String]::IsNullOrWhiteSpace($FilePassword) -eq $false){
        $cmdArgs.Add('Password',$FilePassword)
    }
    if([System.String]::IsNullOrWhiteSpace($Security) -eq $false){
        $cmdArgs.Add('Security',$Security)
    }
    if($null -ne $ServerCredential){
        $cmdArgs.Add('Credential',$ServerCredential)
    }
   
    $result = Restore-ASDatabase @cmdArgs | Select-Object *    
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