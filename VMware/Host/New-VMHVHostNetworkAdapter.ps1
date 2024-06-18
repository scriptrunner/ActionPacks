#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new HostVirtualNIC (Service Console or VMKernel) on the specified host

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
        [sr-en] Name of the host whose network adapter you want to add
        [sr-de] Hostname

    .Parameter SwitchName
        [sr-en] Name of the virtual switch to which you want to add the new network adapter
        [sr-de] Netzwerk-Adapter

    .Parameter PortGroup
        [sr-en] Port group to which you want to add the new adapter
        [sr-de] Portgruppe

    .Parameter AutomaticIPv6
        [sr-en] IPv6 address is obtained through a router advertisement
        [sr-de] IPv6-Adresse von Router

    .Parameter ConsoleNic
        [sr-en] If the value is $true, indicates that you want to create a service console virtual network adapter
        [sr-de] Virtuellen Netzwerk-Adapter für die Dienstkonsole

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
    [string]$SwitchName,
    [Parameter(Mandatory = $true)]
    [string]$PortGroup,
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
    [bool]$VsanTrafficEnabled,
    [switch]$ConsoleNic
)

Import-Module VMware.VimAutomation.Core

try{  
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    $vSwitch = Get-VirtualSwitch -VMHost $vmHost -Name $SwitchName -ErrorAction Stop   
    $vAdapter = New-VMHostNetworkAdapter -VMHost $vmHost -VirtualSwitch $vSwitch -ConsoleNic:$ConsoleNic -AutomaticIPv6:$AutomaticIPv6 `
                            -PortGroup $PortGroup -IPv6ThroughDhcp:$IPv6ThroughDhcp -Confirm:$false -ErrorAction Stop
         
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'VirtualNic' = $Script:vAdapter
                            'Confirm' = $false    
                            }                            
    if($PSBoundParameters.ContainsKey('Dhcp') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -Dhcp:$Dhcp -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('FaultToleranceLoggingEnabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -FaultToleranceLoggingEnabled $FaultToleranceLoggingEnabled -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('IPv4') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -IP $IPv4 | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('IPv6') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -IPv6 $IPv6 | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('IPv6ThroughDhcp') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -IPv6ThroughDhcp $IPv6ThroughDhcp | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('MACAddress') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -MAC $MACAddress | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('ManagementTrafficEnabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -ManagementTrafficEnabled $ManagementTrafficEnabled | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('MtuSize') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -Mtu $MtuSize | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('SubnetMask') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -SubnetMask $SubnetMask | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('VMotionEnabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -VMotionEnabled $VMotionEnabled | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('VsanTrafficEnabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -VsanTrafficEnabled $VsanTrafficEnabled | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('IPv6Enabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -IPv6Enabled $IPv6Enabled | Select-Object *
    }

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