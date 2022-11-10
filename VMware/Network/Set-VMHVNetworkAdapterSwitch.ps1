#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core,VMware.VimAutomation.Vds

<#
    .SYNOPSIS
        Modifies the configuration of the virtual network adapter

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core,VMware.VimAutomation.Vds

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Network

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter VMName
        [sr-en] Virtual machine from which you want to configure the virtual network adapter
        [sr-de] VM des Adapters

    .Parameter TemplateName
        [sr-en] Virtual machine template from which you want to configure the virtual network adapter
        [sr-de] Vorlage des Adapters

    .Parameter SnapshotName
        [sr-en] Snapshot from which you want to configure the virtual network adapter
        [sr-de] Snapshot des Adapters

    .Parameter AdapterName
        [sr-en] Name of the virtual network adapter you want to modify
        [sr-de] Name des Adapters

    .Parameter AdapterType
        [sr-en] Type of the network adapter 
        [sr-de] Typ der Netzwerk-Adapters

    .Parameter MacAddress
        [sr-en] Optional MAC address for the virtual network adapter
        [sr-de] Optionale MAC-Adresse des Netzwerk

    .Parameter Connected
        [sr-en] If the value is $true, the virtual network adapter is connected after its creation
        [sr-de] Virtuellee Netzwerk-Adapter nach seiner Erstellung verbinden 

    .Parameter StartConnected
        [sr-en] If the value is $true, the virtual network adapter starts connected when its associated virtual machine powers on
        [sr-de] Netzwerk-Adapter verbinden, wenn die zugehörige virtuelle Maschine eingeschaltet wird

    .Parameter WakeOnLan
        [sr-en] Wake-on-LAN is enabled on the virtual network adapter
        [sr-de] Wake-On-Lan aktivieren
        
    .Parameter SwitchName
        [sr-en] Name of a virtual switch to which you want to connect the network adapter
        [sr-de] Switch zum Verbinden des Adapters

    .Parameter PortID
        [sr-en] Port of the specified distributed switch to which you want to connect the network adapter
        [sr-de] Port des Adapters
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]    
    [string]$TemplateName,
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$SnapshotName,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$SwitchName,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$PortID,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$AdapterName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [ValidateSet('e1000', 'Flexible', 'Vmxnet', 'EnhancedVmxnet', 'Vmxnet3', 'Unknown')]
    [string]$AdapterType,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$MacAddress,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$Connected,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$StartConnected,    
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$WakeOnLan
)

Import-Module VMware.VimAutomation.Core
Import-Module VMware.VimAutomation.Vds

try{
    if([System.String]::IsNullOrWhiteSpace($AdapterName) -eq $true){
        $AdapterName = "*"
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            }                            
    if($PSCmdlet.ParameterSetName  -eq "Snapshot"){
        $vm = Get-VM @cmdArgs -Name $VMName
        $snap = Get-Snapshot @cmdArgs -Name $SnapshotName -VM $vm
        $cmdArgs.Add('Snapshot', $snap)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Template"){
        $temp = Get-Template @cmdArgs -Name $TemplateName
        $cmdArgs.Add('Template', $temp)
    }
    else {
        $vm = Get-VM @cmdArgs -Name $VMName  
        $cmdArgs.Add('VM', $vm)
    }  
    $adapter = Get-NetworkAdapter @cmdArgs -Name $AdapterName
    $vdSwitch = Get-VDSwitch -Name $SwitchName -Server $Script:vmServer -ErrorAction Stop
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Script:vmServer
                'NetworkAdapter' = $adapter
                'Confirm' = $false
                }               
    $Script:Output = Set-NetworkAdapter @cmdArgs -DistributedSwitch $vdSwitch -PortId $PortID | Select-Object *
    
    if($PSBoundParameters.ContainsKey('AdapterType') -eq $true){
        $Script:Output = Set-NetworkAdapter @cmdArgs -Type $AdapterType | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('MacAddress') -eq $true){
        $Script:Output = Set-NetworkAdapter @cmdArgs -MacAddress $MacAddress | Select-Object *    
    }
    if($PSBoundParameters.ContainsKey('Connected') -eq $true){
        $Script:Output = Set-NetworkAdapter @cmdArgs -Connected $Connected | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('StartConnected') -eq $true){
        $Script:Output = Set-NetworkAdapter @cmdArgs -StartConnected $StartConnected | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('WakeOnLan') -eq $true){
        $Script:Output = Set-NetworkAdapter @cmdArgs -WakeOnLan $WakeOnLan | Select-Object *
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