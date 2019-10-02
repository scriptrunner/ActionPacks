#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

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
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Disks

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMName
    Specifies the name of the virtual machine to which you want to add the new disk

.Parameter DiskName
    Specifies the name of the SCSI hard disk you want to modify

.Parameter DatastoreName
    Indicates that you want to inflate the hard disk

.Parameter Inflate
    Indicates that you want to inflate the hard disk

.Parameter ZeroOut
    Specifies that you want to fill the hard disk with zeros

.Parameter CapacityGB
    Specifies the updated capacity of the virtual disk in gigabytes (GB). 
    This parameter is supported only when the disk type is rawVirtual or flat

.Parameter SCSIControllerName
    Specifies a SCSI controller to which you want to attach the new hard disk

.Parameter Persistence
    Specifies the disk persistence mode

.Parameter DiskType
    Specifies the type of file backing you want to use

.Parameter GuestCredential
    Specifies the PSCredential object that contains the credentials you want to use for authenticating with the guest operating system

.Parameter Partition
    Specifies the partitions you want to resize

.Parameter ToolsWaitSecs
    Specifies the time in seconds to wait for a response from VMware Tools. 
    If a non-positive value is provided, the system waits infinitely long time.
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

Import-Module VMware.PowerCLI

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