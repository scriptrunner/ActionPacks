#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Configures the memory of a virtual machine
    
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

    .Parameter VMName
        Specifies the virtual machine to be configured

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter MemoryType 
        Specifies that the virtual machine is to be configured to use static or dynamic memory

    .Parameter MemoryOnStartup 
        Specifies the amount of memory that the virtual machine is to be allocated upon startup, in bytes

    .Parameter MemoryMinimum 
        Specifies the minimum amount of memory that the virtual machine is to be allocated, in bytes
        
    .Parameter MemoryMaximum
        Specifies the maximum amount of memory that the virtual machine is to be allocated, in bytes

    .Parameter Buffer
        Specifies the percentage of memory to reserve as a buffer in the virtual machine to be configured

    .Parameter Priority
        Sets the priority for memory availability to this virtual machine relative to other virtual machines on the virtual machine host
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [string]$VMName,    
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [ValidateSet('Static', 'Dynamic')]
    [string]$MemoryType = "Static",
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
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
    [int]$Buffer,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateRange(0,100)] 
    [int]$Priority
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
        if($MemoryType -eq "Static"){
            Set-VMMemory -VM $Script:VM -DynamicMemoryEnabled $false -ErrorAction Stop
        }
        else {
            Set-VMMemory -VM $Script:VM -DynamicMemoryEnabled $true -ErrorAction Stop
            if($PSBoundParameters.ContainsKey('MemoryOnStartup') -eq $true ){
                Set-VMMemory -VM $Script:VM -StartupBytes $MemoryOnStartup -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('MemoryMinimum') -eq $true ){
                Set-VMMemory -VM $Script:VM -MinimumBytes $MemoryMinimum -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('MemoryMaximum') -eq $true ){
                Set-VMMemory -VM $Script:VM -MaximumBytes $MemoryMaximum -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('Buffer') -eq $true ){
                Set-VMMemory -VM $Script:VM -Buffer $Buffer -ErrorAction Stop
            }
        }
        if($PSBoundParameters.ContainsKey('Priority') -eq $true ){
            Set-VMMemory -VM $Script:VM -Priority $Priority -ErrorAction Stop
        }
        $output = Get-VMMemory -VM $Script:VM | Select-Object *
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