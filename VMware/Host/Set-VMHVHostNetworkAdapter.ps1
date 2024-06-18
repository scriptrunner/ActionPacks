#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Configures the specified host network adapter

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter HostName
        [sr-en] Name of the host whose network adapter you want to modify
        [sr-de] Hostname

    .Parameter AdapterName
        [sr-en] Name of the host network adapter you want to modify
        [sr-de] Netzwerk-Adapter

    .Parameter AutomaticIPv6
        [sr-en] IPv6 address is obtained through a router advertisement
        [sr-de] IPv6-Adresse von Router

    .Parameter Dhcp
        [sr-en] Host network adapter uses a Dhcp server
        [sr-de] DHCP aktivieren

    .Parameter FaultToleranceLoggingEnabled
        [sr-en] Network adapter is enabled for Fault Tolerance (FT) logging
        [sr-de] Fault Tolerance aktivieren

    .Parameter IPv4
        [sr-en] IP address for the network adapter using an IPv4 dot notation
        [sr-de] IPv4 Adresse

    .Parameter IPv6
        [sr-en] IPv6 address for the network adapter
        [sr-de] IPv6 Adresse

    .Parameter IPv6ThroughDhcp
        [sr-en] IPv6 address is obtained through DHCP
        [sr-en] IPv6-Adresse über DHCP

    .Parameter IPv6Enabled
        [sr-en] IPv6 configuration is enabled
        [sr-de] IPv6 aktivieren

    .Parameter MACAddress
        [sr-en] Media access control (MAC) address of the virtual network adapter
        [sr-de] MAC Adresse

    .Parameter ManagementTrafficEnabled
        [sr-en] Enable the network adapter for management traffic
        [sr-de] Management Traffic aktivieren

    .Parameter MtuSize
        [sr-en] MTU size
        [sr-de] MTU Größe

    .Parameter SubnetMask
        [sr-en] Subnet mask for the NIC
        [sr-de] Subnet Maske

    .Parameter VMotionEnabled
        [sr-en] Virtual host/VMKernel network adapter for VMotion
        [sr-de] VMotion aktivieren

    .Parameter VsanTrafficEnabled
        [sr-en] Virtual SAN traffic is enabled on this network adapter
        [sr-de] Virtual SAN aktivieren
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

Import-Module VMware.VimAutomation.Core

try{  
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:vAdapter = Get-VMHostNetworkAdapter -Server $Script:vmServer -Name $AdapterName -VMHost $HostName -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'VirtualNic' = $Script:vAdapter
                            'Confirm' = $false
                            }                                

    if($PSBoundParameters.ContainsKey('AutomaticIPv6') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -AutomaticIPv6 $AutomaticIPv6
    }
    if($PSBoundParameters.ContainsKey('Dhcp') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -Dhcp:$Dhcp
    }
    if($PSBoundParameters.ContainsKey('FaultToleranceLoggingEnabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -FaultToleranceLoggingEnabled $FaultToleranceLoggingEnabled
    }
    if($PSBoundParameters.ContainsKey('IPv4') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -IP $IPv4
    }
    if($PSBoundParameters.ContainsKey('IPv6') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -IPv6 $IPv6
    }
    if($PSBoundParameters.ContainsKey('IPv6Enabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -IPv6Enabled $IPv6Enabled
    }
    if($PSBoundParameters.ContainsKey('IPv6ThroughDhcp') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -IPv6ThroughDhcp $IPv6ThroughDhcp
    }
    if($PSBoundParameters.ContainsKey('MACAddress') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -Mac $MACAddress
    }
    if($PSBoundParameters.ContainsKey('ManagementTrafficEnabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -ManagementTrafficEnabled $ManagementTrafficEnabled
    }
    if($PSBoundParameters.ContainsKey('MtuSize') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -Mtu $MtuSize
    }
    if($PSBoundParameters.ContainsKey('SubnetMask') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -SubnetMask $SubnetMask
    }
    if($PSBoundParameters.ContainsKey('VMotionEnabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -VMotionEnabled $VMotionEnabled
    }
    if($PSBoundParameters.ContainsKey('VsanTrafficEnabled') -eq $true){
        $Script:vAdapter = Set-VMHostNetworkAdapter @cmdArgs -VsanTrafficEnabled $VsanTrafficEnabled
    }
    $result = $Script:vAdapter | Select-Object *

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
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}