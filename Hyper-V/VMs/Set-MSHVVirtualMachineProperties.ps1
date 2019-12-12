#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Sets the properties for the virtual machine.
        Only parameters with value are set
    
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
        Specifies the name or identifier of the virtual machine to be retrieved   

    .Parameter Notes
        Specifies notes to be associated with the virtual machine

    .Parameter SnapshotFileLocation
        Specifies the folder in which the virtual machine is to store its snapshot files

    .Parameter ProcessorCount
        Specifies the number of virtual processors for the virtual machine

    .Parameter NewName
        Specifies the name to which the virtual machine is to be renamed

    .Parameter MemoryType 
        Specifies that the virtual machine is to be configured to use static or dynamic memory

    .Parameter MemoryOnStartup 
        Specifies the amount of memory that the virtual machine is to be allocated upon startup, in bytes

    .Parameter MemoryMinimum 
        Specifies the minimum amount of memory that the virtual machine is to be allocated, in bytes
        
    .Parameter MemoryMaximum
        Specifies the maximum amount of memory that the virtual machine is to be allocated, in bytes

    .Parameter MemoryBuffer
        Specifies the percentage of memory to reserve as a buffer in the virtual machine to be configured

    .Parameter MemoryPriority
        Sets the priority for memory availability to this virtual machine relative to other virtual machines on the virtual machine host

    .Parameter SwitchName
        Specifies the name of the virtual switch to which the virtual network adapter is to be connected

    .Parameter DisconnectExistingAdapters
        Disconnects existing network adapters from the virtual machine

    .Parameter SnapshotFileLocation
        Specifies the folder in which the virtual machine is to store its snapshot files

    .Parameter SmartPagingFilePath
        Specifies the folder in which the Smart Paging file is to be stored
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
    [string]$Notes,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$SnapshotFileLocation,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$ProcessorCount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$NewName, 
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Static', 'Dynamic')]
    [string]$MemoryType ,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [uint64]$MemoryOnStartup,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [uint64]$MemoryMinimum,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [uint64]$MemoryMaximum,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateRange(5,2000)] 
    [int]$MemoryBuffer,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateRange(0,100)] 
    [int]$MemoryPriority,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$SwitchName,    
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$DisconnectExistingAdapters
)

Import-Module Hyper-V

try {    
    $Script:output
    [string[]]$Properties = @('VMName','VMID','State','PrimaryOperationalStatus','PrimaryStatusDescription','ProcessorCount','MemoryStartup','DynamicMemoryEnabled','MemoryMinimum','MemoryMaximum','Notes','SnapshotFileLocation')
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
        if($PSBoundParameters.ContainsKey('Notes') -eq $true){
            Set-VM -VM $Script:VM -Notes $Notes -ErrorAction Stop
        } 
        if($PSBoundParameters.ContainsKey('ProcessorCount') -eq $true){
            Set-VM -VM $Script:VM -ProcessorCount $ProcessorCount -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('NewName') -eq $true){
            Set-VM -VM $Script:VM -NewVMName $NewName -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('SnapshotFileLocation') -eq $true){
            Set-VM -VM $Script:VM -SnapshotFileLocation $SnapshotFileLocation -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('SmartPagingFilePath') -eq $true){
            Set-VM -VM $Script:VM -SmartPagingFilePath $SmartPagingFilePath -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('MemoryType') -eq $true ){
            if($MemoryType -eq "Static"){
                Set-VMMemory -VM $Script:VM -DynamicMemoryEnabled $false -ErrorAction Stop
            }
            else {
                Set-VMMemory -VM $Script:VM -DynamicMemoryEnabled $true -ErrorAction Stop
            }
        }
        if($PSBoundParameters.ContainsKey('MemoryOnStartup') -eq $true ){
            Set-VMMemory -VM $Script:VM -StartupBytes $MemoryOnStartup -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('MemoryBuffer') -eq $true ){
            $tmp = Get-VMMemory -VM $Script:VM | Select-Object *
            if($tmp.DynamicMemoryEnabled -eq $true){
                Set-VMMemory -VM $Script:VM -Buffer $MemoryBuffer -ErrorAction Stop                
            }            
        }
        if($PSBoundParameters.ContainsKey('MemoryMinimum') -eq $true ){
            $tmp = Get-VMMemory -VM $Script:VM | Select-Object *
            if($tmp.DynamicMemoryEnabled -eq $true){
                Set-VMMemory -VM $Script:VM -MinimumBytes $MemoryMinimum -ErrorAction Stop                
            }            
        }
        if($PSBoundParameters.ContainsKey('MemoryMaximum') -eq $true ){
            $tmp = Get-VMMemory -VM $Script:VM | Select-Object *
            if($tmp.DynamicMemoryEnabled -eq $true){
                Set-VMMemory -VM $Script:VM -MaximumBytes $MemoryMaximum -ErrorAction Stop                
            }            
        }
        if($PSBoundParameters.ContainsKey('MemoryPriority') -eq $true ){
            Set-VMMemory -VM $Script:VM -Priority $MemoryPriority -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('MemoryType') -eq $true ){
            if($MemoryType -eq "Static"){
                Set-VMMemory -VM $Script:VM -DynamicMemoryEnabled $false -ErrorAction Stop
            }
            else {
                Set-VMMemory -VM $Script:VM -DynamicMemoryEnabled $true -ErrorAction Stop
            }
        }
        if($DisconnectExistingAdapters -eq $true){
            Get-VMNetworkAdapter -VM $Script:VM | Disconnect-VMNetworkAdapter -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('SwitchName') -eq $true ){
            if($null -eq $Script:Cim){
                Connect-VMNetworkAdapter -ComputerName $HostName -VMName $Script:VM.VMname -SwitchName $SwitchName -Confirm:$false -ErrorAction Stop
            }
            else {
                Connect-VMNetworkAdapter -CimSession $Script:Cim -VMName $Script:VM.VMname -SwitchName $SwitchName -Confirm:$false -ErrorAction Stop
            }
        }
        if($null -eq $AccessAccount){
            $Script:output = Get-VM -ComputerName $HostName -Name $Script:VM.VMName | Select-Object $Properties
            $Properties = @('Name','VMName','MacAddress','DynamicMacAddressEnabled','IPAddresses','Connected','SwitchName','AdapterId','Status','StatusDescription','IsManagementOs','IsExternalAdapter')
            $Script:output += Get-VMNetworkAdapter -VM $Script:VM | Select-Object $Properties | Where-Object {$_.Connected -eq $true}
        }
        else {
            $Script:output += Get-VM -CimSession $Script:Cim -Name $Script:VM.VMName | Select-Object $Properties
        } 
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:output
        }    
        else {
            Write-Output $Script:output
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