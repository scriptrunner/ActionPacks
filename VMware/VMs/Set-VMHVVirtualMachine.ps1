#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies the configuration of the virtual machine

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
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMId
    Specifies the ID of the virtual machine you want to configure

.Parameter VMName
    Specifies the name of the virtual machine you want to configure

.Parameter Notes
    Provides a description for the virtual machine

.Parameter Cpus
    Specifies the number of the virtual CPUs

.Parameter CoresPerSocket
    Specifies the number of virtual CPU cores per socket

.Parameter MemoryGB
    Specifies the memory size in gigabytes (GB)

.Parameter Network 
    Specifies the network to which you want to connect the virtual machine

.Parameter GuestId
    Specifies the guest operating system

.Parameter OSCustomizationSpec
    [sr-en] Customization specification that is to be applied to the virtual machine. 
    This works only in 32-bit mode 
    [sr-de] Benutzerdefinierte Einstellungen der virtuellen Maschine
    Nur für 32Bit

.Parameter HardwareVersion
    Specifies the version to which you want to upgrade the virtual machine. 
    You cannot downgrade to an earlier version

.Parameter VMSwapfilePolicy
    Specifies the swapfile placement policy

.Parameter NewName
    Specifies a new name for the virtual machine
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$Notes,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$Cpus,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$CoresPerSocket,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [decimal]$MemoryGB,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$Network,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$GuestId,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$OSCustomizationSpec,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$HardwareVersion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("WithVM","Inherit","InHostDatastore")]
    [string]$VMSwapfilePolicy,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewName
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @('Name','Id','NumCpu','CoresPerSocket','Notes','GuestId','MemoryGB','VMSwapfilePolicy','ProvisionedSpaceGB','Folder')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }

    if($Cpus -gt 0){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -NumCpu $Cpus -Confirm:$False -ErrorAction Stop
    }
    if($CoresPerSocket -gt 0){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -CoresPerSocket $CoresPerSocket -Confirm:$False -ErrorAction Stop
    }
    if($MemoryGB -gt 0){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -MemoryGB $MemoryGB -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('Notes') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -Notes $Notes -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('GuestId') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -GuestId $GuestId -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('OSCustomizationSpec') -eq $true){
        $spec = Get-OSCustomizationSpec -Name $OSCustomizationSpec -Server $Script:vmServer
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -OSCustomizationSpec $spec -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HardwareVersion') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -HardwareVersion $HardwareVersion -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('Network') -eq $true){
        $adapter = Get-NetworkAdapter -Server $Script:vmServer -VM $Script:machine
        $null = Set-NetworkAdapter -NetworkName $Network -NetworkAdapter $adapter -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('VMSwapfilePolicy') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -VMSwapfilePolicy $VMSwapfilePolicy -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -Name $NewName -Confirm:$False -ErrorAction Stop
    }

    $result = Get-VM -Server $Script:vmServer -ID $Script:machine.Id | Select-Object $Properties
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