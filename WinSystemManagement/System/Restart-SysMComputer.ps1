#Requires -Version 4.0

<#
.SYNOPSIS
    Restarts ("reboots") the operating system computers. 
    Type the computer names or type IP addresses in IPv4 or IPv6 format. Use the comma to separate the names

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System

.Parameter ComputerNames
    Specifies one or more computers

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter DcomAuthentication
    Specifies the authentication level that this cmdlet uses with WMI

.Parameter Delay
    Determines how often, in seconds, Windows PowerShell queries the service that is specified by the For parameter to determine whether it is available after the computer is restarted
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerNames,    
    [PSCredential]$AccessAccount,
    [ValidateSet("Default","None","Connect","Call","Packet","PacketIntegrity","PacketPrivacy","Unchanged")]
    [string]$DcomAuthentication = "Packet"
)

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'DcomAuthentication' = $DcomAuthentication
                            'Confirm' = $false
                            'Force' = $true
                            }

    if($null -ne $AccessAccount){
        $cmdArgs.Add('Credential', $AccessAccount)
    }
    $null = Restart-Computer @cmdArgs -ComputerName $ComputerNames.Split(',') 

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Computers restarted"
    }
    else{
        Write-Output "Computers restarted"
    }
}
catch{
    throw
}
finally{
}