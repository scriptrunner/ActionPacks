#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Configures the specified host network adapter

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter HostName
    Specifies the name of the host whose network adapter you want to modify

.Parameter AdapterName
    Specifies the name of the host network adapter you want to modify

.Parameter AutomaticIPv6
    Indicates that the IPv6 address is obtained through a router advertisement

.Parameter Dhcp
    Indicates whether the host network adapter uses a Dhcp server

.Parameter FaultToleranceLoggingEnabled
    Indicates that the network adapter is enabled for Fault Tolerance (FT) logging

.Parameter IPv4
    Specifies an IP address for the network adapter using an IPv4 dot notation

.Parameter IPv6
    Specifies an IPv6 address for the network adapter

.Parameter IPv6ThroughDhcp
    Indicates that the IPv6 address is obtained through DHCP

.Parameter IPv6Enabled
    Indicates that IPv6 configuration is enabled

.Parameter MACAddress
    Specifies the media access control (MAC) address of the virtual network adapter

.Parameter ManagementTrafficEnabled
    Indicates that you want to enable the network adapter for management traffic

.Parameter MtuSize
    Specifies the MTU size

.Parameter SubnetMask
    Specifies a subnet mask for the NIC

.Parameter VMotionEnabled
    Indicates that you want to use the virtual host/VMKernel network adapter for VMotion

.Parameter VsanTrafficEnabled
    Specifies whether Virtual SAN traffic is enabled on this network adapter
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [Parameter(Mandatory = $true)]
    [string]$AdapterName,
    [bool]$AutomaticIPv6,
    [switch]$Dhcp,
    [bool]$FaultToleranceLoggingEnabled,
    [string]$IPv4,
    [string]$IPv6,
    [bool]$IPv6Enabled,
    [bool]$IPv6ThroughDhcp,
    [string]$MACAddress,
    [bool]$ManagementTrafficEnabled,
    [int32]$MtuSize,
    [string]$SubnetMask,
    [bool]$VMotionEnabled,
    [bool]$VsanTrafficEnabled
)

Import-Module VMware.PowerCLI

try{  
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:vAdapter = Get-VMHostNetworkAdapter -Server $Script:vmServer -Name $AdapterName -VMHost $HostName -ErrorAction Stop
    if($PSBoundParameters.ContainsKey('AutomaticIPv6') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -AutomaticIPv6 $AutomaticIPv6 -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('Dhcp') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -Dhcp:$Dhcp -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('FaultToleranceLoggingEnabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -FaultToleranceLoggingEnabled $FaultToleranceLoggingEnabled -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IPv4') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -IP $IPv4 -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IPv6') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -IPv6 $IPv6 -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IPv6Enabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -IPv6Enabled $IPv6Enabled -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IPv6ThroughDhcp') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -IPv6ThroughDhcp $IPv6ThroughDhcp -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('MACAddress') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -Mac $MACAddress -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ManagementTrafficEnabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -ManagementTrafficEnabled $ManagementTrafficEnabled -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('MtuSize') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -Mtu $MtuSize -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SubnetMask') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -SubnetMask $SubnetMask -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('VMotionEnabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -VMotionEnabled $VMotionEnabled -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('VsanTrafficEnabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter -VirtualNic $Script:vAdapter -VsanTrafficEnabled $VsanTrafficEnabled -Confirm:$false -ErrorAction Stop
    }
    $Script:Output = $Script:vAdapter | Select-Object *

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}