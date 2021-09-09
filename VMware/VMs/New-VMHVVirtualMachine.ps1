#Requires -Version 5.0
# Requires -Modules VMware.PowerCLI

<#
    .SYNOPSIS
        Creates a new virtual machine

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VMs

    .Parameter VIServer
        [sr-en] Specifies the IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des VSphere Servers

    .Parameter VICredential
        [sr-en] Specifies a PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter HostName
        [sr-en] Specifies the name of the host on which you want to create the new virtual machine
        [sr-de] Host in dem die neue virtuellen Maschine erstellt wird 

    .Parameter VMName
        [sr-en] Specifies a name for the new virtual machine
        [sr-de] Name der virtuellen Maschine

    .Parameter Notes
        [sr-en] Provides a description of the new virtual machine
        [sr-de] Beschreibung

    .Parameter Cpus
        [sr-en] Specifies the number of the virtual CPUs of the new virtual machine
        [sr-de] Anzahl der virtuellen CPUs

    .Parameter CoresPerSocket
        [sr-en] Specifies the number of virtual CPU cores per socket
        [sr-de] Anzahl der virtuellen CPUs pro Socket

    .Parameter MemoryGB
        [sr-en] Specifies the memory size in gigabytes (GB) of the new virtual machine 
        [sr-de] Größe des Arbeitsspeichers in Gigabyte (GB)

    .Parameter DiskGB
        [sr-en] Specifies the size in gigabytes (GB) of the disks that you want to create and add to the new virtual machine
        [sr-de] Größe der Festplatte in Gigabyte (GB)

    .Parameter DiskStorageFormat
        [sr-en] Specifies the storage format of the disks of the virtual machine 
        [sr-de] Dateisystem der Festplatte

    .Parameter CD
        [sr-en] Indicates that you want to add a CD drive to the new virtual machine 
        [sr-de] CD-Laufwerk zur neuen virtuellen Maschine hinzufügen

    .Parameter Floppy
        [sr-en] Indicates that you want to add a floppy drive to the new virtual machine 
        [sr-de] Diskettenlaufwerk zur neuen virtuellen Maschine hinzufügen

    .Parameter Network 
        [sr-en] Specifies the network to which you want to connect the new virtual machine 
        [sr-de] Netzwerk der neuen virtuellen Maschine

    .Parameter GuestId
        [sr-en] Specifies the guest operating system of the new virtual machine 
        [sr-de] Identifier des Betriebssystems der neuen virtuellen Maschine

    .Parameter OSCustomizationSpec
        [sr-en] Specifies a customization specification that is to be applied to the new virtual machine. 
        This works only in 32-bit mode 
        [sr-de] Benutzerdefinierte Einstellungen der neuen virtuellen Maschine
        Nur für 32Bit

    .Parameter HardwareVersion
        [sr-en] Specifies the version of the new virtual machine. 
        By default, the new virtual machine is created with the latest available version 
        [sr-de] Hardware Version der neuen virtuellen Maschine

    .Parameter Location
        [sr-en] Specifies the folder where you want to place the new virtual machine 
        [sr-de] Ordner der neuen virtuellen Maschine

    .Parameter Datastore
        [sr-en] Specifies the datastore where you want to place the new virtual machine 
        [sr-de] Datastore der neuen virtuellen Maschine   

    .Parameter VMSwapfilePolicy
        [sr-en] Specifies the swapfile placement policy
        [sr-de] Swapfile Placement Policy
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
    [ValidateSet("e1000","Flexible","Vmxnet","EnhancedVmxnet","Vmxnet3")]
    [string]$NetworkAdapterType = "e1000",
    [string]$GuestId,
    [string]$OSCustomizationSpec,
    [string]$HardwareVersion,
    [string]$Location,
    [string]$Datastore,
    [ValidateSet("WithVM","Inherit","InHostDatastore")]
    [string]$VMSwapfilePolicy = "Inherit"
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @('Name','Id','NumCpu','CoresPerSocket','Notes','GuestId','MemoryGB','VMSwapfilePolicy','ProvisionedSpaceGB','Folder')
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

    if([System.String]::IsNullOrEmpty($Datastore) -eq $false){
        $store = Get-Datastore -Server $Script:vmServer -Name $Datastore -ErrorAction Stop
        $cmdArgs.Add('Datastore' ,$store)
    }
    if([System.String]::IsNullOrEmpty($Location) -eq $false){
        $folder = Get-Folder -Server $Script:vmServer -Name $Location -ErrorAction Stop
        $cmdArgs.Add('Location' ,$Folder)
    }
    if($PSBoundParameters.ContainsKey('OSCustomizationSpec') -eq $true){
        $spec = Get-OSCustomizationSpec -Name $OSCustomizationSpec -Server $Script:vmServer
        $cmdArgs.Add('OSCustomizationSpec' ,$spec)
    }
    $Script:machine = New-VM @cmdArgs

    if($PSBoundParameters.ContainsKey('GuestId') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -GuestId $GuestId -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HardwareVersion') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -HardwareVersion $HardwareVersion -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('Network') -eq $true){
        $adapter = Get-NetworkAdapter -Server $Script:vmServer -VM $Script:machine
        $null = Set-NetworkAdapter -NetworkName $Network -NetworkAdapter $adapter -Type $NetworkAdapterType -Confirm:$false -ErrorAction Stop
    }

    $result = Get-VM -Server $Script:vmServer -Name $VMName | Select-Object $Properties
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