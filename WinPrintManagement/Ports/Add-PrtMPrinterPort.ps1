#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Installs a local, TCP, LPR or TCP LPR printer port on the specified computer

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

.Parameter HostName
    Specifies the host name of the computer on which to add LPR printer port

.Parameter PrinterName
    Specifies the name of the printer installed on the LPR printer port

.Parameter PrinterHostAddress
    Specifies the host address of the TCP/IP printer port added to the specified computer

.Parameter PortNumber
    Specifies the TCP/IP port number for the printer port added to the specified computer

.Parameter LprHostAddress
    Specifies the LPR host address when installing a TCP/IP printer port in LPR mode

.Parameter LprQueueName
    Specifies the LPR queue name when installing a TCP/IP printer port in LPR mode.

.Parameter SNMP
    Enables SNMP and specifies the index for TCP/IP printer port management

.Parameter SNMPCommunity
    Specifies the SNMP community name for TCP/IP printer port management

.Parameter ComputerName
    Specifies the name of the computer to which to add the printer port
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local")]
    [Parameter(Mandatory = $true,ParameterSetName = "TCP Port")]
    [Parameter(Mandatory = $true,ParameterSetName = "TCP LPR Port")]
    [string]$PortName,
    [Parameter(Mandatory = $true,ParameterSetName = "LPR Port")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "LPR Port")]
    [string]$PrinterName,
    [Parameter(Mandatory = $true,ParameterSetName = "TCP Port")]
    [string]$PrinterHostAddress,
    [Parameter(Mandatory = $true,ParameterSetName = "TCP Port")]
    [int]$PortNumber,
    [Parameter(Mandatory = $true,ParameterSetName = "TCP LPR Port")]
    [string]$LprHostAddress,
    [Parameter(Mandatory = $true,ParameterSetName = "TCP LPR Port")]
    [string]$LprQueueName,
    [Parameter(ParameterSetName = "TCP Port")]
    [Parameter(ParameterSetName = "TCP LPR Port")]
    [int]$SNMP,
    [Parameter(ParameterSetName = "TCP Port")]
    [Parameter(ParameterSetName = "TCP LPR Port")]
    [string]$SNMPCommunity,
    [Parameter(ParameterSetName = "Local")]
    [Parameter(ParameterSetName = "LPR Port")]    
    [Parameter(ParameterSetName = "TCP Port")]
    [Parameter(ParameterSetName = "TCP LPR Port")]
    [string]$ComputerName,
    [Parameter(ParameterSetName = "Local")]
    [Parameter(ParameterSetName = "LPR Port")]
    [Parameter(ParameterSetName = "TCP Port")]
    [Parameter(ParameterSetName = "TCP LPR Port")]
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
    if($PSCmdlet.ParameterSetName  -eq "Local"){
        Add-PrinterPort -CimSession $Script:Cim -ComputerName $ComputerName -Name $PortName 
    }
    if($PSCmdlet.ParameterSetName  -eq "LPR Port"){
        Add-PrinterPort -CimSession $Script:Cim -ComputerName $ComputerName -HostName $HostName -PrinterName $PrinterName
        $Script:Port =Get-PrinterPort -Name $PrinterName
    }
    if($PSCmdlet.ParameterSetName  -eq "TCP Port"){
        if([System.string]::IsNullOrWhiteSpace($SNMPCommunity) -and $SNMP -le 0){
            Add-PrinterPort -CimSession $Script:Cim -ComputerName $ComputerName -PrinterHostAddress $PrinterHostAddress `
                                        -Name $PortName -PortNumber $PortNumber
        }
        else {
            Add-PrinterPort -CimSession $Script:Cim -ComputerName $ComputerName -PrinterHostAddress $PrinterHostAddress -PortNumber $PortNumber `
                    -SNMP $SNMP -SNMPCommunity $SNMPCommunity -Name $PortName
        }
    }
    if($PSCmdlet.ParameterSetName  -eq "TCP LPR Port"){
        if([System.string]::IsNullOrWhiteSpace($SNMPCommunity) -and $SNMP -le 0){
            Add-PrinterPort -CimSession $Script:Cim -ComputerName $ComputerName -Name $PortName `
                         -LprHostAddress $LprHostAddress -LprQueueName $LprQueueName
        }
        else{
            Add-PrinterPort -CimSession $Script:Cim -ComputerName $ComputerName -Name $PortName `
                            -LprHostAddress $LprHostAddress -LprQueueName $LprQueueName `
                            -SNMP $SNMP -SNMPCommunity $SNMPCommunity 
        }
    }
    if($null -eq $Script:Port){
        $Script:Port =Get-PrinterPort -Name $PortName
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Port 
    }
    else{
        Write-Output $Script:Port
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