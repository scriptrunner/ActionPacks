#Requires -Version 4.0
#Requires -Modules NetTcpIp

<#
.SYNOPSIS
    Gets the IP address configuration

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module NetTcpIp

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Network

.Parameter AdapterName
    Specifies the friendly name of the interface. If the parameter is empty, the ip addresses from all adapters are retrieved
    
.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the dns client
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$AdapterName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [ValidateSet('*','Name','InterfaceAlias','InterfaceIndex','AddressFamily','AddressState','IPv4Address','IPv6Address','SubnetMask','IPAddress','Type')]
    [string[]]$Properties = @('Name','InterfaceAlias','InterfaceIndex','AddressFamily','AddressState','IPv4Address','IPv6Address','SubnetMask','IPAddress','Type')
)

Import-Module nettcpip

$Script:Cim
try{
    if([System.String]::IsNullOrWhiteSpace($AdapterName)){
        $AdapterName = "*"
    }
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    
    $result = Get-NetIPAddress -CimSession $Script:Cim -ErrorAction Stop `
                    | Where-Object{$_.InterfaceAlias -like $AdapterName } | Select-Object $Properties
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
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}