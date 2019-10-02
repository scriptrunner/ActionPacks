#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new virtual network adapter

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Network

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMName
    Specifies the virtual machine from which you want to configure the virtual network adapter

.Parameter AdapterType
    Specifies the type of the network adapter

.Parameter Network
    Specifies the name of the network to which you want to connect the virtual network adapter   

.Parameter PortGroupName
    Specifies a standard or a distributed port group to which you want to connect the new network adapter

.Parameter SwitchName
    Specifies a virtual switch to which you want to connect the network adapter

.Parameter PortID
    Specifies the port of the specified distributed switch to which you want to connect the network adapter

.Parameter MacAddress
    Specifies an optional MAC address for the virtual network adapter

.Parameter AdapterType
    Specifies the type of the new network adapter 

.Parameter StartConnected
    If the value is $true, the virtual network adapter starts connected when its associated virtual machine powers on

.Parameter WakeOnLan
    Indicates that wake-on-LAN is enabled on the virtual network adapter
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [Parameter(Mandatory = $true,ParameterSetName = "Switch")]
    [Parameter(Mandatory = $true,ParameterSetName = "PortGroup")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [Parameter(Mandatory = $true,ParameterSetName = "Switch")]
    [Parameter(Mandatory = $true,ParameterSetName = "PortGroup")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [Parameter(Mandatory = $true,ParameterSetName = "Switch")]
    [Parameter(Mandatory = $true,ParameterSetName = "PortGroup")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "Default")]
    [string]$Network,
    [Parameter(Mandatory = $true,ParameterSetName = "PortGroup")]
    [string]$PortGroupName,
    [Parameter(Mandatory = $true,ParameterSetName = "Switch")]
    [string]$SwitchName,
    [Parameter(Mandatory = $true,ParameterSetName = "Switch")]
    [string]$PortID,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Switch")]
    [Parameter(ParameterSetName = "PortGroup")]
    [ValidateSet('e1000', 'Flexible', 'Vmxnet', 'EnhancedVmxnet', 'Vmxnet3', 'Unknown')]
    [string]$AdapterType,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Switch")]
    [Parameter(ParameterSetName = "PortGroup")]
    [string]$MacAddress,
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Switch")]
    [Parameter(ParameterSetName = "PortGroup")]
    [switch]$StartConnected,    
    [Parameter(ParameterSetName = "Default")]
    [Parameter(ParameterSetName = "Switch")]
    [Parameter(ParameterSetName = "PortGroup")]
    [switch]$WakeOnLan
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    if($PSCmdlet.ParameterSetName  -eq "Switch"){
        $vdSwitch = Get-VDSwitch -Name $SwitchName -Server $Script:vmServer -ErrorAction Stop
        $Script:adapter = New-NetworkAdapter -Server $Script:vmServer -VM $vm -DistributedSwitch $vdSwitch -PortId $PortID -WakeOnLan:$WakeOnLan -StartConnected:$StartConnected -ErrorAction Stop
    }
    elseif($PSCmdlet.ParameterSetName  -eq "PortGroup"){
        $vdGroup = Get-VDPortgroup -Name $PortGroupName -Server $Script:vmServer -ErrorAction Stop
        $Script:adapter = New-NetworkAdapter -Server $Script:vmServer -VM $vm -Portgroup $vdGroup -WakeOnLan:$WakeOnLan -StartConnected:$StartConnected -ErrorAction Stop
    }
    else{
        $Script:adapter = New-NetworkAdapter -Server $Script:vmServer -VM $vm -NetworkName $Network -WakeOnLan:$WakeOnLan -StartConnected:$StartConnected -ErrorAction Stop
    }
    
    if($PSBoundParameters.ContainsKey('AdapterType') -eq $true){
        $Script:Output = Set-NetworkAdapter -Server $Script:vmServer -NetworkAdapter $Script:adapter -Type $AdapterType -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('MacAddress') -eq $true){
        $Script:Output = Set-NetworkAdapter -Server $Script:vmServer -NetworkAdapter $Script:adapter -MacAddress $MacAddress -Confirm:$false -ErrorAction Stop | Select-Object *    
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