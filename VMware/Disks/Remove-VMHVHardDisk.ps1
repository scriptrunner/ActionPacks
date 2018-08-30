#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Removes the specified virtual hard disk

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Disks

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMName
    Specifies the virtual machine from which you want to remove the hard disk

.Parameter TemplateName
    Specifies the virtual machine template from which you want to remove the hard disk

.Parameter SnapshotName
    Specifies the snapshot from which you want to remove the hard disk

.Parameter DiskName
    Specifies the name of the SCSI hard disk you want to remove

.Parameter DeletePermanently
    Indicates that you want to delete the hard disks not only from the inventory, but from the datastore as well
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
    [string]$DiskName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [switch]$DeletePermanently
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if($PSCmdlet.ParameterSetName  -eq "Snapshot"){
        $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
        $snap = Get-Snapshot -Server $Script:vmServer -Name $SnapshotName -VM $vm -ErrorAction Stop
        $Script:harddisk = Get-HardDisk -Server $Script:vmServer -Snapshot $snap -Name $DiskName -ErrorAction Stop        
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Template"){
        $temp = Get-Template -Server $Script:vmServer -Name $TemplateName -ErrorAction Stop
        $Script:harddisk = Get-HardDisk -Server $Script:vmServer -Template $temp -Name $DiskName -ErrorAction Stop
    }
    else {
        $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop        
        $Script:harddisk = Get-HardDisk -Server $Script:vmServer -VM $vm -Name $DiskName -ErrorAction Stop
    }
    Remove-HardDisk -HardDisk $Script:harddisk -DeletePermanently:$DeletePermanently -Confirm:$false -ErrorAction Stop

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Disk $($DiskName) successfully removed"
    }
    else{
        Write-Output "Disk $($DiskName) successfully removed"
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