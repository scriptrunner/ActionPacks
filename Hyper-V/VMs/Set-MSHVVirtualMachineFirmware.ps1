#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Sets the firmware configuration of a virtual machine
        This is only supported on Generation 2 virtual machines
    
    .DESCRIPTION
        Use "Win2K12R2 or Win8.x" for execution on Windows Server 2012 R2 or on Windows 8.1,
        when execute on Windows Server 2016 / Windows 10 or newer, use "Newer Systems"  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Hyper-V

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/VMs

    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter VMName
        Specifies the name or identifier of the virtual machine whose firmware is to be retrieved.Parameter VMName
        Specifies the name or identifier of the virtual machine whose BIOS is to be retrieved

    .Parameter EnableSecureBoot
        Specifies whether to enable secure boot

    .Parameter StartUpOrder1
        Specifies the boot device #1 in the BIOS of the virtual machine

    .Parameter StartUpOrder2
        Specifies the boot device #2 in the BIOS of the virtual machine

    .Parameter StartUpOrder3
        Specifies the boot device #3 in the BIOS of the virtual machine

    .Parameter PreferredNetworkBootProtocol
        Specifies the IP protocol version to use during a network boot
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [string]$VMName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('On','Off')]
    $EnableSecureBoot = 'Off',
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('DVDDrive', 'HardDiskDrive', 'NetworkAdapter')]
    [string]$StartUpOrder1 = "DVDDrive",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('None', 'DVDDrive', 'HardDiskDrive', 'NetworkAdapter')]
    [string]$StartUpOrder2 = "HardDiskDrive",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('None', 'DVDDrive', 'HardDiskDrive', 'NetworkAdapter')]
    [string]$StartUpOrder3 = "NetworkAdapter",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('IPv4', 'IPv6')]
    $PreferredNetworkBootProtocol = 'IPv4'
)

Import-Module Hyper-V

try {
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    if($null -eq $AccessAccount){
        $Script:VM = Get-VM -ComputerName $HostName -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:VM = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }        
    if($null -ne $Script:VM){
        [object[]]$Script:start = @()
        $disk = Get-VMHardDiskDrive -VM $Script:VM
        $dvd = Get-VMDvdDrive -VM $Script:VM
        $network = Get-VMNetworkAdapter -VM $Script:VM
        if($StartUpOrder1 -eq 'DVDDrive' -and $null -ne $dvd){
            $Script:start += $dvd
            $dvd = $null
        }
        if($StartUpOrder1 -eq 'HardDiskDrive' -and $null -ne $disk){
            $Script:start += $disk
            $disk = $null
        }
        if($StartUpOrder1 -eq 'NetworkAdapter' -and $null -ne $network){
            $Script:start += $network
            $network = $null
        }
        if($StartUpOrder2 -eq 'DVDDrive' -and $null -ne $dvd){
            $Script:start += $dvd
            $dvd = $null
        }
        if($StartUpOrder2 -eq 'HardDiskDrive' -and $null -ne $disk){
            $Script:start += $disk
            $disk = $null
        }
        if($StartUpOrder2 -eq 'NetworkAdapter' -and $null -ne $network){
            $Script:start += $network
            $network = $null
        }
        if($StartUpOrder3 -eq 'DVDDrive' -and $null -ne $dvd){
            $Script:start += $dvd
            $dvd = $null
        }
        if($StartUpOrder3 -eq 'HardDiskDrive' -and $null -ne $disk){
            $Script:start += $disk
            $disk = $null
        }
        if($StartUpOrder3 -eq 'NetworkAdapter' -and $null -ne $network){
            $Script:start += $network
            $network = $null
        }
        Set-VMFirmware -VM $Script:VM -EnableSecureBoot $EnableSecureBoot -BootOrder $Script:start -PreferredNetworkBootProtocol $PreferredNetworkBootProtocol -ErrorAction Stop
        $output = Get-VMFirmware -VM $Script:VM | Select-Object *
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $output
        }    
        else {
            Write-Output $output
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Virtual machine $($VMName) not found"
        }    
        Throw "Virtual machine $($VMName) not found"
    }
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}