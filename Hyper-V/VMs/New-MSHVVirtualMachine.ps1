#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Creates a new virtual machine
    
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

    .Parameter VMName
        Specifies the name of the new virtual machine. The default name is New virtual machine

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter VHDPath
        Specifies the path to a existing virtual hard disk file

    .Parameter NewVHDPath
        Creates a new virtual hard disk with the specified path and connects it to the new virtual machine, e.g. C:\vhds\myvm.vhdx. 
        Absolute paths are allowed. 
        If only a file name is specified, the virtual hard disk is created in the default path configured for the host

    .Parameter NewVHDSize
        Specifies the size of the dynamic virtual hard disk that is created and attached to the new virtual machine, in bytes

    .Parameter NoVHD
        Creates a virtual machine without attaching any virtual hard disks

    .Parameter BootDevice
        Specifies the device to use as the boot device for the new virtual machine

    .Parameter Generation
        Specifies the generation, as an integer, for the virtual machine

    .Parameter StartupMemory
        Specifies the amount of memory, in bytes, to assign to the virtual machine, in bytes

    .Parameter FilePath
        Specifies the directory to store the files for the new virtual machine

    .Parameter SwitchName
        Specifies the friendly name of the virtual switch if you want to connect the new virtual machine to an existing virtual switch to provide connectivity to a network

    .Parameter ProcessorCount
        Specifies the number of virtual processors for the virtual machine

    .Parameter DynamicMemory 
        Specifies whether dynamic memory is to be enabled on the virtual machine to be configured

    .Parameter MemoryMinimum 
        Specifies the minimum amount of memory that the virtual machine is to be allocated, in bytes
        
    .Parameter MemoryMaximum
        Specifies the maximum amount of memory that the virtual machine is to be allocated, in bytes

    .Parameter Notes
        Specifies notes to be associated with the virtual machine
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$VMName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$VHDPath,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$NewVHDPath,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [uint64]$NewVHDSize,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$NoVHD,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Floppy', 'CD', 'IDE', 'LegacyNetworkAdapter', 'NetworkAdapter', 'VHD')]
    [string]$BootDevice = "VHD",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet(1,2)] 
    [int16]$Generation = 2,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [uint64]$StartupMemory = 536870912 ,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$FilePath,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$SwitchName,    
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$ProcessorCount = 1,    
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$DynamicMemory,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [uint64]$MemoryMinimum,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [uint64]$MemoryMaximum,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$Notes
)

Import-Module Hyper-V

try {
    $Script:output
    [string[]]$Properties = @('VMName','VMID','State','PrimaryOperationalStatus','PrimaryStatusDescription','CPUUsage','MemoryDemand','SizeOfSystemFiles','IntegrationServicesVersion')
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    if([System.String]::IsNullOrWhiteSpace($VMName)){
        $VMName = " "
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName' ,$HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession' ,$Script:Cim)
    }
    
    if([System.String]::IsNullOrWhiteSpace($FilePath)){
        $vmHost = Get-VMHost @cmdArgs | Select-Object *
        $FilePath = $vmHost.VirtualMachinePath
    }
    $cmdArgs.Add('Name', $VMName )
    $cmdArgs.Add('MemoryStartupBytes', $StartupMemory )
    $cmdArgs.Add('Generation', $Generation)
    $cmdArgs.Add('BootDevice', $BootDevice)
    $cmdArgs.Add('Path', $FilePath)
    $cmdArgs.Add('Force', $null)
    if(($PSBoundParameters.ContainsKey('NewVHDPath') -eq $true)  -and (-not [System.String]::IsNullOrWhiteSpace($NewVHDPath))){
        if($NewVHDSize -lt 1048576){ # lower then 1 MB
            $NewVHDSize = 1073741824 # default 1 GB
        }
        $Script:VM = New-VM @cmdArgs -NewVHDPath $NewVHDPath -NewVHDSizeBytes $NewVHDSize
    }
    elseif(($PSBoundParameters.ContainsKey('VHDPath') -eq $true)  -and (-not [System.String]::IsNullOrWhiteSpace($VHDPath))){
        $Script:VM = New-VM @cmdArgs -VHDPath $VHDPath

    }
    else{
        $Script:VM = New-VM @cmdArgs -NoVHD        
    }
    $cmdArgs = @{'ErrorAction' = 'Stop'}
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName' ,$HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession' ,$Script:Cim)
    }
    if($PSBoundParameters.ContainsKey('SwitchName') -eq $true){
        Connect-VMNetworkAdapter @cmdArgs -VMName $Script:VM.VMName -SwitchName $SwitchName
    }       

    if($ProcessorCount -gt 1){
        Set-VM -VM $Script:VM -ProcessorCount $ProcessorCount -ErrorAction Stop
    }
    if($DynamicMemory -eq $true){
        Set-VMMemory -VM $Script:VM -DynamicMemoryEnabled $true -ErrorAction Stop
        if($PSBoundParameters.ContainsKey('MemoryOnStartup') -eq $true ){
            Set-VMMemory -VM $Script:VM -StartupBytes $StartupMemory -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('MemoryMinimum') -eq $true ){
            Set-VMMemory -VM $Script:VM -MinimumBytes $MemoryMinimum -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('MemoryMaximum') -eq $true ){
            Set-VMMemory -VM $Script:VM -MaximumBytes $MemoryMaximum -ErrorAction Stop
        }
    }
    $output = Get-VM @cmdArgs -Id $Script:VM.Id | Select-Object $Properties
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    }    
    else {
        Write-Output $output
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