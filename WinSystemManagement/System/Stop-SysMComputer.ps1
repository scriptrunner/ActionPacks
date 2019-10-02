#Requires -Version 4.0

<#
.SYNOPSIS
    Stops (shuts down) the computers. 
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
    $test = Get-Host | Select-Object -ExpandProperty Version
    if($test.Major -lt 5  ){
        if($null -eq $AccessAccount){
            Stop-Computer -ComputerName $ComputerNames.Split(',') -Confirm:$false -Force -Authentication $DcomAuthentication
        }
        else {
            Stop-Computer -ComputerName $ComputerNames.Split(',') -Credential $AccessAccount -Confirm:$false -Force -Authentication $DcomAuthentication
        }
    }
    else {
        if($null -eq $AccessAccount){
            Stop-Computer -ComputerName $ComputerNames.Split(',') -Confirm:$false -Force -DcomAuthentication $DcomAuthentication    
        }
        else {
            Stop-Computer -ComputerName $ComputerNames.Split(',') -Credential $AccessAccount -Confirm:$false -Force -DcomAuthentication $DcomAuthentication 
        }    
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Computers stopped"
    }
    else{
        Write-Output "Computers stopped"
    }
}
catch{
    throw
}
finally{
}