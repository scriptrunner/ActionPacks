#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Get the Login objects in an instance of SQL Server

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

.Parameter OnlyDisabled
    Indicates that this cmdlet gets only disabled Login objects

.Parameter OnlyHasAccess
    Indicates that this cmdlet gets only Login objects that have access to the instance of SQL Server
        
.Parameter OnlyLocked
    Indicates that this cmdlet gets only locked Login objects

.Parameter OnlyPasswordExpired
    Indicates that this cmdlet gets only Login objects that have expired passwords

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [switch]$OnlyDisabled,
    [switch]$OnlyHasAccess,
    [switch]$OnlyLocked,
    [switch]$OnlyPasswordExpired,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'ServerInstance' = $ServerInstance
                            'ConnectionTimeout' = $ConnectionTimeout}
    if($null -ne $ServerCredential){
        $cmdArgs.Add('Credential',$ServerCredential)
    }
    $instance = Get-SqlInstance @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'InputObject' = $instance
                'Disabled' = $OnlyDisabled.ToBool()
                'Locked' = $OnlyLocked.ToBool()
                'PasswordExpired' = $OnlyPasswordExpired.ToBool()
                'HasAccess' = $OnlyHasAccess.ToBool()
                }

    $result = Get-SqlLogin @cmdArgs | Select-Object Name | Sort-Object Name
    foreach($itm in  $result){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.Name) # Value
            $null = $SRXEnv.ResultList2.Add($itm.Name)
        }
        else{
            Write-Output $itm.Name
        }
    }
}
catch{
    throw
}
finally{
}