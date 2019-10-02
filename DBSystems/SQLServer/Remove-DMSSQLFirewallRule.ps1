#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Disables the Windows Firewall rule that allows connections to a specific instance of SQL Server. 
    SQL Server Cloud Adapter must be installed

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

.Parameter ManagementPublicPort
    Specifies the public management port on the target machine

.Parameter RetryTimeout
    Specifies the time period to retry the command on the target server

.Parameter AutomaticallyAcceptUntrustedCertificates
    Indicates that this cmdlet automatically accepts untrusted certificates

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [Parameter(Mandatory = $true)] 
    [pscredential]$ServerCredential,
    [int]$RetryTimeout,
    [int]$ManagementPublicPort,
    [switch]$AutomaticallyAcceptUntrustedCertificates,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $instance
                            'Credential' = $ServerCredential
                            'AutomaticallyAcceptUntrustedCertificates' = $AutomaticallyAcceptUntrustedCertificates.ToBool()
                            'Confirm' = $false
                            }
    
    if($ManagementPublicPort -gt 0){
        $cmdArgs.Add('ManagementPublicPort',$ManagementPublicPort)
    }
    if($RetryTimeout -gt 0){
        $cmdArgs.Add('RetryTimeout',$RetryTimeout)
    }
    $null = Remove-SqlFirewallRule @cmdArgs
        
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Firewall rule removed"
    }
    else{
        Write-Output "Firewall rule removed"
    }
}
catch{
    throw
}
finally{
}