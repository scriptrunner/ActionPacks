#Requires -Version 5.0
#Requires -Modules VMware.VIMAutomation.Core

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
        Requires Module VMware.VIMAutomation.Core

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder FQDN des VSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto zur Authentifizierung am VSphere Server

    .Parameter VM
        [sr-en] Virtual machine you want to configure
        [sr-de] VM

    .Parameter Notes
        [sr-en] Description for the virtual machine
        [sr-de] Beschreibung der VM

    .Parameter Cpus
        [sr-en] Number of the virtual CPUs
        [sr-de] Anzahl der Cpus

    .Parameter CoresPerSocket
        [sr-en] Number of virtual CPU cores per socket
        [sr-de] Anzahl der Cpus pro Sockel

    .Parameter MemoryGB
        [sr-en] Memory size in gigabytes (GB)
        [sr-de] Speicher in Gigabyte (GB)

    .Parameter Network 
        [sr-en] Network to which you want to connect the virtual machine
        [sr-de] Netzwerk

    .Parameter GuestId
        [sr-en] Guest operating system
        [sr-de] Betriebssystem

    .Parameter OSCustomizationSpec
        [sr-en] Customization specification that is to be applied to the virtual machine. 
        This works only in 32-bit mode 
        [sr-de] Benutzerdefinierte Einstellungen der virtuellen Maschine
        Nur für 32Bit

    .Parameter HardwareVersion
        [sr-en] Version to which you want to upgrade the virtual machine. 
        You cannot downgrade to an earlier version
        [sr-de] Neue Version der VM

    .Parameter VMSwapfilePolicy
        [sr-en] Swapfile placement policy
        [sr-de] Regel für die Auslagerungsdatei

    .Parameter NewName
        [sr-en] New name for the virtual machine
        [sr-de] Neuer Name der VM

    .Parameter GuestDiskTotal
        [sr-en] ReadOnly: Total size of the guest disk in gigabytes (GB)
        [sr-de] ReadOnly: Größe der Betriebssystemfestplatte in Gigabytes (GB) 

    .Parameter GuestDiskFree
        [sr-en] ReadOnly: Free size on the guest disk in gigabytes (GB)
        [sr-de] ReadOnly: Freier Platz auf der Betriebssystemfestplatte in Gigabytes (GB)         

    .Parameter CpuUsageAverage
        [sr-en] ReadOnly: Cpu usage average
        [sr-de] ReadOnly: Durchschnittliche Cpu Auslastung 

    .Parameter MemoryUsageAverage
        [sr-en] ReadOnly: Memory usage average
        [sr-de] ReadOnly: Durchschnittliche Speicher Auslastung 
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "Splatting")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "Splatting")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "Splatting",HelpMessage="ASRDisplay(Splatting)")]
    [hashtable]$VM,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [string]$Notes,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [int32]$Cpus,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [int32]$CoresPerSocket,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting",HelpMessage="ASRDisplay(Alias=Memory)")]
    [decimal]$MemoryGB,
    [Parameter(ParameterSetName = "Splatting",HelpMessage="ASRDisplay(ReadOnly)")]
    [string]$CpuUsageAverage,
    [Parameter(ParameterSetName = "Splatting",HelpMessage="ASRDisplay(ReadOnly)")]
    [string]$MemoryUsageAverage,
    [Parameter(ParameterSetName = "Splatting",HelpMessage="ASRDisplay(ReadOnly)")]
    [decimal]$GuestDiskTotal,
    [Parameter(ParameterSetName = "Splatting",HelpMessage="ASRDisplay(ReadOnly)")]
    [decimal]$GuestDiskFree,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [string]$Network,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [string]$GuestId,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [string]$OSCustomizationSpec,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [string]$HardwareVersion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [ValidateSet("WithVM","Inherit","InHostDatastore")]
    [string]$VMSwapfilePolicy,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "Splatting")]
    [string]$NewName
)

Import-Module VMware.VIMAutomation.Core

try{
    [string[]]$Properties = @('Name','Id','NumCpu','CoresPerSocket','Notes','GuestId','MemoryGB','VMSwapfilePolicy','ProvisionedSpaceGB','Folder')
    $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $machine = Get-VM -Server $vmServer -Id $VMId -ErrorAction Stop
    }
    elseif($PSCmdlet.ParameterSetName -eq "Splatting"){
        $machine = Get-VM -Server $vmServer -Id $VM.Id -ErrorAction Stop
    }
    else{
        $machine = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
    }

    if($PSCmdlet.ParameterSetName -eq "Splatting"){
        if($Cpus -gt $machine.NumCpu){
            $null = Set-VM -Server $vmServer -VM $machine -NumCpu $Cpus -Confirm:$False -ErrorAction Stop
        }
        if($CoresPerSocket -gt $machine.CoresPerSocket){
            $null = Set-VM -Server $vmServer -VM $machine -CoresPerSocket $CoresPerSocket -Confirm:$False -ErrorAction Stop
        }
        if($MemoryGB -gt $machine.MemoryGB){
            $null = Set-VM -Server $vmServer -VM $machine -MemoryGB $MemoryGB -Confirm:$False -ErrorAction Stop
        }
        if($Notes -cne $machine.Notes){
            $null = Set-VM -Server $vmServer -VM $machine -Notes $Notes -Confirm:$False -ErrorAction Stop
        }
    }
    else{
        if($Cpus -gt 0){
            $null = Set-VM -Server $vmServer -VM  $machine -NumCpu $Cpus -Confirm:$False -ErrorAction Stop
        }
        if($CoresPerSocket -gt 0){
            $null = Set-VM -Server $vmServer -VM  $machine -CoresPerSocket $CoresPerSocket -Confirm:$False -ErrorAction Stop
        }
        if($MemoryGB -gt 0){
            $null = Set-VM -Server $vmServer -VM  $machine -MemoryGB $MemoryGB -Confirm:$False -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('Notes') -eq $true){
            $null = Set-VM -Server $vmServer -VM  $machine -Notes $Notes -Confirm:$False -ErrorAction Stop
        }
    }

    if($PSBoundParameters.ContainsKey('GuestId') -eq $true){
        $null = Set-VM -Server $vmServer -VM  $machine -GuestId $GuestId -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('OSCustomizationSpec') -eq $true){
        $spec = Get-OSCustomizationSpec -Name $OSCustomizationSpec -Server $vmServer
        $null = Set-VM -Server $vmServer -VM  $machine -OSCustomizationSpec $spec -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HardwareVersion') -eq $true){
        $null = Set-VM -Server $vmServer -VM  $machine -HardwareVersion $HardwareVersion -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('Network') -eq $true){
        $adapter = Get-NetworkAdapter -Server $vmServer -VM $machine
        $null = Set-NetworkAdapter -NetworkName $Network -NetworkAdapter $adapter -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('VMSwapfilePolicy') -eq $true){
        $null = Set-VM -Server $vmServer -VM  $machine -VMSwapfilePolicy $VMSwapfilePolicy -Confirm:$False -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        $null = Set-VM -Server $vmServer -VM  $machine -Name $NewName -Confirm:$False -ErrorAction Stop
    }

    $result = Get-VM -Server $vmServer -ID $machine.Id | Select-Object $Properties
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
    if($null -ne $vmServer){
        Disconnect-VIServer -Server $vmServer -Force -Confirm:$false
    }
}