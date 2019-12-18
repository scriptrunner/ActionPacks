#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Installs a local, TCP, LPR or TCP LPR printer port on the specified computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

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
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CimSession' = $Script:Cim 
                            'ComputerName' = $ComputerName}
    if($PSCmdlet.ParameterSetName  -eq "Local"){
        $cmdArgs.Add('Name', $PortName )
    }
    if($PSCmdlet.ParameterSetName  -eq "LPR Port"){
        $cmdArgs.Add('HostName', $HostName)
        $cmdArgs.Add('PrinterName', $PrinterName)
        $null = Add-PrinterPort @cmdArgs
        $Script:Port = Get-PrinterPort -Name $PrinterName
    }
    if($PSCmdlet.ParameterSetName  -eq "TCP Port"){
        $cmdArgs.Add('PrinterHostAddress', $PrinterHostAddress)
        $cmdArgs.Add('Name', $PortName) 
        $cmdArgs.Add('PortNumber', $PortNumber)
        if(([System.string]::IsNullOrWhiteSpace($SNMPCommunity) -eq $false) -and ($SNMP -gt 0)){
            $cmdArgs.Add('SNMP', $SNMP)
            $cmdArgs.Add('SNMPCommunity', $SNMPCommunity)
        }
    }
    if($PSCmdlet.ParameterSetName  -eq "TCP LPR Port"){
        $cmdArgs.Add('LprHostAddress', $LprHostAddress)
        $cmdArgs.Add('Name', $PortName) 
        $cmdArgs.Add('LprQueueName', $LprQueueName)
        if(([System.string]::IsNullOrWhiteSpace($SNMPCommunity) -eq $false) -and ($SNMP -gt 0)){
            $cmdArgs.Add('SNMP', $SNMP)
            $cmdArgs.Add('SNMPCommunity', $SNMPCommunity)
        }
    }
    if($null -eq $Script:Port){
        $null = Add-PrinterPort @cmdArgs
        $Script:Port = Get-PrinterPort -Name $PortName
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