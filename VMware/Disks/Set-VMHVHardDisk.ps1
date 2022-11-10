#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Modifies the properties of the specified virtual hard disk

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Disks

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter VMName
        [sr-en] Name of the virtual machine to which you want to add the new disk
        [sr-de] Virtuelle Maschine

    .Parameter DiskName
        [sr-en] Name of the SCSI hard disk you want to modify
        [sr-de] SCSI Laufwerk

    .Parameter DatastoreName
        [sr-en] Datastore
        [sr-de] Datastore

    .Parameter Inflate
        [sr-en] Inflate the hard disk
        [sr-de] Festplatte erweitern

    .Parameter ZeroOut
        [sr-en] Fill the hard disk with zeros
        [sr-de] Festplatte mit Nullen auffüllen

    .Parameter CapacityGB
        [sr-en] Specifies the updated capacity of the virtual disk in gigabytes (GB). 
        This parameter is supported only when the disk type is rawVirtual or flat
        [sr-de] Aktualisierte Kapazität der virtuellen Festplatte, in Gigabyte

    .Parameter SCSIControllerName
        [sr-en] SCSI controller to which you want to attach the new hard disk
        [sr-de] SCSI-Kontroller

    .Parameter Persistence
        [sr-en] Disk persistence mode
        [sr-de] Festplatten Persistenz-Modus

    .Parameter DiskType
        [sr-en] Type of file backing you want to use
        [sr-de] Typ der Dateisicherung

    .Parameter GuestCredential
        [sr-en] PSCredential object that contains the credentials you want to use for authenticating with the guest operating system
        [sr-de] Benutzerkonto des Betriebssystems

    .Parameter Partition
        [sr-en] Partition you want to resize
        [sr-de] Partition zum Vergrößern

    .Parameter ToolsWaitSecs
        [sr-en] Time in seconds to wait for a response from VMware Tools. 
        If a non-positive value is provided, the system waits infinitely long time.
        [sr-de] Wartezeit in Sekunden, auf die VMware Tools
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Update")]
    [Parameter(Mandatory = $true,ParameterSetName = "ResizeGuestSystem")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Update")]
    [Parameter(Mandatory = $true,ParameterSetName = "ResizeGuestSystem")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Update")]
    [Parameter(Mandatory = $true,ParameterSetName = "ResizeGuestSystem")]
    [string]$VMName,    
    [Parameter(Mandatory = $true,ParameterSetName = "Update")]
    [Parameter(Mandatory = $true,ParameterSetName = "ResizeGuestSystem")]
    [string]$DiskName,
    [Parameter(ParameterSetName = "Update")]
    [Parameter(ParameterSetName = "ResizeGuestSystem")]
    [decimal]$CapacityGB,
    [Parameter(ParameterSetName = "Update")]
    [switch]$Inflate,
    [Parameter(ParameterSetName = "Update")]
    [switch]$ZeroOut,
    [Parameter(ParameterSetName = "Update")]
    [string]$SCSIControllerName,
    [Parameter(ParameterSetName = "Update")]
    [Validateset("Persistent", "NonPersistent", "IndependentPersistent", "IndependentNonPersistent", "Undoable")]
    [string]$Persistence,    
    [Parameter(ParameterSetName = "ResizeGuestSystem")]
    [pscredential]$GuestCredential,
    [Parameter(ParameterSetName = "ResizeGuestSystem")]
    [string]$Partition,
    [Parameter(ParameterSetName = "ResizeGuestSystem")]
    [int32]$ToolsWaitSecs = 20
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop        
    $Script:harddisk = Get-HardDisk -Server $Script:vmServer -VM $vm -Name $DiskName -ErrorAction Stop

    if($CapacityGB -gt 0){
        if($PSCmdlet.ParameterSetName  -eq "Update"){
            $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -CapacityGB $CapacityGB -Confirm:$false -ErrorAction Stop
        }
        else {
            if($PSBoundParameters.ContainsKey('GuestCredential') -eq $true){
                $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -CapacityGB $CapacityGB -GuestCredential $GuestCredential -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
            }
            else{
                $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -CapacityGB $CapacityGB -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
            }
        }
    }
    if($PSBoundParameters.ContainsKey('SCSIControllerName') -eq $true){
        $controller = Get-ScsiController -Server $Script:vmServer -VM $Script:vm -Name $SCSIControllerName -ErrorAction Stop
        if($PSCmdlet.ParameterSetName  -eq "Update"){
            $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -Controller $controller -Confirm:$false -ErrorAction Stop
        }
        else {
            $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -Controller $controller -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
        }
    }
    if($PSBoundParameters.ContainsKey('Persistence') -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "Update"){
            $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -Persistence $Persistence -Confirm:$false -ErrorAction Stop
        }
        else {
            $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -Persistence $Persistence -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
        }
    }
    if($PSBoundParameters.ContainsKey('Inflate') -eq $true){
        $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -Inflate:$Inflate -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ZeroOut') -eq $true){
        $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -ZeroOut:$ZeroOut -Confirm:$false -ErrorAction Stop    
    }

    $Script:Output = $Script:harddisk | Select-Object *
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
    if($null -ne $Script:vmServer) {
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}