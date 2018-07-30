#Requires -Version 4.0

<#
.SYNOPSIS
    Sets DNS server addresses associated with the TCP/IP properties on an interface

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    
.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/Network

.Parameter AdapterName
    Specifies the friendly name of the interface. The cmdlet modifies IP addresses that match the alias
    
.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the dns client
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter IPAddresses
    Specifies a list of DNS server IP addresses to set for the interface
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$AdapterName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$IPAddresses
)

[string[]]$Script:Properties = @("ServerAddresses","ElementName","Name","InterfaceAlias","InterfaceIndex","Address","EnabledState")
$Script:Cim
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    Set-DNSClientServerAddress -CimSession $Script:Cim -InterfaceAlias $AdapterName -ServerAddresses $IPAddresses -Confirm:$false -Validate -ErrorAction Stop
    $Script:Msg = Get-DNSClientServerAddress -CimSession $Script:Cim -InterfaceAlias $AdapterName | Select-Object $Script:Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Msg
    }
    else{
        Write-Output $Script:Msg
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