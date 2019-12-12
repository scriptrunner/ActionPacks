#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Configures the type of snapshots and the folder in which the virtual machine is to store its snapshot files
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/Snapshots

    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter VMName
        Specifies the virtual machine to be configured

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter SnapshotType
        Specifies the type of snapshots created by Hyper-V

    .Parameter SnapshotLocation
        Specifies the folder in which the virtual machine is to store its snapshot files
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
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Standard','Disabled','Production','ProductionOnly')]
    [string]$SnapshotType = "Standard",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$SnapshotLocation
)

Import-Module Hyper-V

try {
    [string[]]$Script:Properties = @('SnapshotFileLocation','CheckpointType','VMName','VMID','State','PrimaryOperationalStatus','PrimaryStatusDescription','CPUUsage','MemoryDemand','SizeOfSystemFiles','IntegrationServicesVersion')
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
        $Script:Properties = @('SnapshotFileLocation','VMName','VMID','State','PrimaryOperationalStatus','PrimaryStatusDescription','CPUUsage','MemoryDemand','SizeOfSystemFiles','IntegrationServicesVersion')
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
        if($PSBoundParameters.ContainsKey('SnapshotType')){
            Set-VM -VM $Script:VM -CheckpointType $SnapshotType -ErrorAction Stop            
        }
        if(-not [System.String]::IsNullOrWhiteSpace($SnapshotLocation)){
            Set-VM -VM $Script:VM -SnapshotFileLocation $SnapshotLocation -ErrorAction Stop            
        }
        if($null -eq $AccessAccount){
            $Script:output = Get-VM -ComputerName $HostName -Name $Script:VM.VMName | Select-Object $Script:Properties
        }
        else {
            $Script:output = Get-VM -CimSession $Script:Cim -Name $Script:VM.VMName | Select-Object $Script:Properties
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