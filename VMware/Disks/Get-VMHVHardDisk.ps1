#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the virtual hard disks available on a vCenter Server system

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
    Specifies the virtual machine from which you want to retrieve the hard disks

.Parameter TemplateName
    Specifies the virtual machine template from which you want to retrieve the hard disks

.Parameter SnapshotName
    Specifies the snapshot from which you want to retrieve the hard disks

.Parameter DatastoreName
    Specifies the name of the datastore you want to search for hard disks

.Parameter DiskName
    Specifies the name of the SCSI hard disk you want to retrieve, is the parameter empty all SCSI hard disks retrieved

.Parameter DiskID
    Specifies the ID of the hard disk you want to retrieve
    
.Parameter DiskType
    Specifies the type of the hard disk you want to retrieve
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [Parameter(Mandatory = $true,ParameterSetName = "Datastore")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [Parameter(Mandatory = $true,ParameterSetName = "Datastore")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]    
    [string]$TemplateName,
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$SnapshotName,
    [Parameter(Mandatory = $true,ParameterSetName = "Datastore")]
    [string]$DatastoreName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [Parameter(ParameterSetName = "Datastore")]
    [string]$DiskName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [Parameter(ParameterSetName = "Datastore")]
    [string]$DiskID,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [Parameter(ParameterSetName = "Datastore")]
    [ValidateSet("rawVirtual", "rawPhysical", "flat","unknown")]
    [string]$DiskType
)

Import-Module VMware.PowerCLI

try{
    if([System.String]::IsNullOrWhiteSpace($DiskName) -eq $true){
        $DiskName = "*"
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if($PSCmdlet.ParameterSetName  -eq "Snapshot"){
        $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
        $snap = Get-Snapshot -Server $Script:vmServer -Name $SnapshotName -VM $vm -ErrorAction Stop
        if([System.String]::IsNullOrWhiteSpace($DiskID) -eq $true){
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Snapshot $snap -Name $DiskName -ErrorAction Stop | Select-Object *
            }
            else {
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Snapshot $snap -Name $DiskName -DiskType $DiskType -ErrorAction Stop | Select-Object *
                
            }            
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Snapshot $snap -Id $DiskID -ErrorAction Stop | Select-Object *
            }
            else {
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Snapshot $snap -Id $DiskID -DiskType $DiskType -ErrorAction Stop | Select-Object *
            }
        }
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Template"){
        $temp = Get-Template -Server $Script:vmServer -Name $TemplateName -ErrorAction Stop
        if([System.String]::IsNullOrWhiteSpace($DiskID) -eq $true){
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Template $temp -Name $DiskName -ErrorAction Stop | Select-Object *
            }
            else {
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Template $temp -Name $DiskName -DiskType $DiskType -ErrorAction Stop | Select-Object *
                
            }            
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Template $temp -Id $DiskID -ErrorAction Stop | Select-Object *
            }
            else {
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Template $temp -Id $DiskID -DiskType $DiskType -ErrorAction Stop | Select-Object *
            }
        }
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Datastore"){
        $store = Get-Datastore -Server $Script:vmServer -Name $DatastoreName -ErrorAction Stop
        if([System.String]::IsNullOrWhiteSpace($DiskID) -eq $true){
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Datastore $store -ErrorAction Stop | Select-Object *
            }
            else {
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Datastore $store -DiskType $DiskType -ErrorAction Stop | Select-Object *
                
            }            
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Datastore $store -Id $DiskID -ErrorAction Stop | Select-Object *
            }
            else {
                $Script:Output = Get-HardDisk -Server $Script:vmServer -Datastore $store -Id $DiskID -DiskType $DiskType -ErrorAction Stop | Select-Object *
            }
        }
    }
    else {
        $vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop        
        if([System.String]::IsNullOrWhiteSpace($DiskID) -eq $true){
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $Script:Output = Get-HardDisk -Server $Script:vmServer -VM $vm -Name $DiskName -ErrorAction Stop | Select-Object *
            }
            else {
                $Script:Output = Get-HardDisk -Server $Script:vmServer -VM $vm -Name $DiskName -DiskType $DiskType -ErrorAction Stop | Select-Object *
                
            }            
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $Script:Output = Get-HardDisk -Server $Script:vmServer -VM $vm -Id $DiskID -ErrorAction Stop | Select-Object *
            }
            else {
                $Script:Output = Get-HardDisk -Server $Script:vmServer -VM $vm -Id $DiskID -DiskType $DiskType -ErrorAction Stop | Select-Object *
            }
        }
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