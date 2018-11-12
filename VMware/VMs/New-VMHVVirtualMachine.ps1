#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new virtual machine

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VMs

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter HostName
    Specifies the name of the host on which you want to create the new virtual machine

.Parameter VMName
    Specifies a name for the new virtual machine

.Parameter Notes
    Provides a description of the new virtual machine

.Parameter Cpus
    Specifies the number of the virtual CPUs of the new virtual machine

.Parameter CoresPerSocket
    Specifies the number of virtual CPU cores per socket

.Parameter MemoryGB
    Specifies the memory size in gigabytes (GB) of the new virtual machine

.Parameter DiskGB
    Specifies the size in gigabytes (GB) of the disks that you want to create and add to the new virtual machine

.Parameter DiskStorageFormat
    Specifies the storage format of the disks of the virtual machine

.Parameter CD
    Indicates that you want to add a CD drive to the new virtual machine

.Parameter Floppy
    Indicates that you want to add a floppy drive to the new virtual machine

.Parameter Network 
    Specifies the network to which you want to connect the new virtual machine

.Parameter GuestId
    Specifies the guest operating system of the new virtual machine

.Parameter OSCustomizationSpec
    Specifies a customization specification that is to be applied to the new virtual machine

.Parameter HardwareVersion
    Specifies the version of the new virtual machine. 
    By default, the new virtual machine is created with the latest available version

.Parameter Location
    Specifies the folder where you want to place the new virtual machine

.Parameter VMSwapfilePolicy
    Specifies the swapfile placement policy
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
    [string]$VMName,
    [string]$Notes,
    [int32]$Cpus = 1,
    [int32]$CoresPerSocket = 1,
    [decimal]$MemoryGB,
    [decimal]$DiskGB,
    [ValidateSet("Thin", "Thick","EagerZeroedThick")]
    [string]$DiskStorageFormat = "Thick",
    [switch]$Floppy,
    [switch]$CD,
    [string]$Network,
    [string]$GuestId,
    [ValidateSet("NonPersistent","Persistent")]
    [string]$OSCustomizationSpec,
    [string]$HardwareVersion,
    [string]$Location,
    [ValidateSet("WithVM","Inherit","InHostDatastore")]
    [string]$VMSwapfilePolicy = "Inherit"
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @("Name","Id","NumCpu","CoresPerSocket","Notes","GuestId","MemoryGB","VMSwapfilePolicy","ProvisionedSpaceGB","Folder")
    if([System.String]::IsNullOrWhiteSpace($Notes) -eq $true){
        $Notes = " "
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'Name' = $VMName 
                            'VMHost' = $vmHost 
                            'Notes' = $Notes 
                            'Confirm' = $false
                            'NumCpu' = $Cpus
                            'CoresPerSocket' = $CoresPerSocket 
                            'MemoryGB' = $MemoryGB
                            'DiskGB' = $DiskGB
                            'Floppy' = $Floppy 
                            'CD' = $CD 
                            'DiskStorageFormat' = $DiskStorageFormat
                            'VMSwapfilePolicy' = $VMSwapfilePolicy
                        }

    if([System.String]::IsNullOrEmpty($Location) -eq $false){
        $folder = Get-Folder -Server $Script:vmServer -Name $Location -ErrorAction Stop
        $cmdArgs.Add('Location' ,$Folder)
    }
    $Script:machine = New-VM @cmdArgs
    if($PSBoundParameters.ContainsKey('GuestId') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -GuestId $GuestId -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('OSCustomizationSpec') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -OSCustomizationSpec $OSCustomizationSpec -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HardwareVersion') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -HardwareVersion $HardwareVersion -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('Network') -eq $true){
        $adapter = Get-NetworkAdapter -Server $Script:vmServer -VM $Script:machine
        $null = Set-NetworkAdapter -NetworkName $Network -NetworkAdapter $adapter -Confirm:$false -ErrorAction Stop
    }

    $Script:output = Get-VM -Server $Script:vmServer -Name $VMName | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
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