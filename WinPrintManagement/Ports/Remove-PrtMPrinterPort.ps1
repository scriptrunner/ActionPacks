#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Removes the specified printer port from the computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Ports

.Parameter PortName
    Specifies the name of the printer port

.Parameter ComputerName
    Specifies the name of the computer from which remove the printer port
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PortName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module PrintManagement

$Script:Cim=$null
try{    
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    Remove-PrinterPort -CimSession $Script:Cim -ComputerName $ComputerName -Name $PortName  
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Printer port: $($PortName) removed from Computer: $($ComputerName)" 
    }
    else{
        Write-Output "Printer port: $($PortName) removed from Computer: $($ComputerName)"
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}