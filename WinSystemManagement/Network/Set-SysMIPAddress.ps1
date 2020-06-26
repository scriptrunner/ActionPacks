#Requires -Version 4.0
#Requires -Modules NetTcpIp

<#
.SYNOPSIS
    Modifies the configuration of an IP address

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
    Specifies the friendly name of the interface. The cmdlet modifies IP addresses that match the alias
    
.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the dns client
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter IPAddress
    Specifies the IPv4 or IPv6 address to replace

.Parameter DefaultGateway 
    Specifies the IPv4 address or IPv6 address of the default gateway for the host

.Parameter AddressFamily
    Specifies an array of IP address families. The cmdlet modifies the IP address configuration that matches the families
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$AdapterName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$IPAddress,
    [byte]$PrefixLength, 
    [string]$DefaultGateway,
    [ValidateSet("IPv4","IPv6")]
    [string]$AddressFamily
)

Import-Module nettcpip

[string]$Script:Properties = @("Name","InterfaceAlias","InterfaceIndex","AddressFamily","AddressState","IPv4Address","IPv6Address","SubnetMask","IPAddress","Type")
$Script:Cim
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
    $old = Get-NetIPAddress -CimSession $Script:Cim -InterfaceAlias $AdapterName -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CimSession' = $Script:Cim
                            'InterfaceAlias' = $AdapterName 
                            'IPAddress' = $IPAddress
                            }
    if([System.String]::IsNullOrWhiteSpace($AddressFamily) -eq $false){
        $cmdArgs.Add('AddressFamily', $AddressFamily)
    }
    if([System.String]::IsNullOrWhiteSpace($DefaultGateway) -eq $false){
        $cmdArgs.Add('DefaultGateway', $DefaultGateway)
    }
    if($PrefixLength -gt 0){
        $cmdArgs.Add('PrefixLength', $PrefixLength)
    }
    $null = New-NetIPAddress @cmdArgs

    if($null -ne $old){
        $null = Remove-NetIPAddress -InputObject $old -Confirm:$false -ErrorAction Stop
    }

    $result = Get-NetIPAddress -CimSession $Script:Cim -InterfaceAlias $AdapterName -ErrorAction Stop | Select-Object $Script:Properties
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