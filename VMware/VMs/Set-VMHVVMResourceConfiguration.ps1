#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Configures resource allocation between the virtual machine

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
    Specifies the ID of the virtual machine you want to remove

.Parameter VMName
    Specifies the name of the virtual machine you want to remove

.Parameter DiskName
    Specifies the name of the virtual hard disk you want to configure

.Parameter CpuLimitMhz
    Specifies the limit on CPU usage in MHz

.Parameter CpuReservationMhz
    Specifies the number of CPU MHz that are guaranteed to be available

.Parameter CpuSharesLevel
    Specifies the CPU allocation level

.Parameter MemLimitGB
    Specifies a memory usage limit in gigabytes

.Parameter MemReservationGB
    Specifies the guaranteed available memory in gigabytes 

.Parameter MemSharesLevel
    Specifies the memory allocation level for this pool

.Parameter NumCpuShares
    Specifies the CPU allocation level for this pool

.Parameter NumMemShares
    Specifies the number of memory shares allocated
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
    [string]$DiskName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int64]$CpuLimitMhz,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int64]$CpuReservationMhz,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$CpuSharesLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [decimal]$MemLimitGB,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [decimal]$MemReservationGB,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$MemSharesLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$NumCpuShares,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$NumMemShares

)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }
    $Script:disk = $null
    $Script:resConfig = Get-VMResourceConfiguration -Server $Script:vmServer -VM $Script:machine -ErrorAction Stop
    if([System.String]::IsNullOrWhiteSpace($DiskName) -eq $false){
        $Script:disk = Get-HardDisk -VM $Script:machine -Name $DiskName -Server $Script:vmServer -ErrorAction Stop
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Configuration' = $Script:resConfig                            
                            'Confirm' = $false}
                            
    if($null -ne $Script:disk){
        $cmdArgs.Add('Disk' , $Script:disk)
    }
    if($PSBoundParameters.ContainsKey('CpuLimitMhz') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -CpuLimitMhz $CpuLimitMhz
    }
    if($PSBoundParameters.ContainsKey('CpuReservationMhz') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -CpuReservationMhz $CpuReservationMhz
    }
    if($PSBoundParameters.ContainsKey('CpuSharesLevel') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -CpuSharesLevel $CpuSharesLevel
    }
    if($PSBoundParameters.ContainsKey('MemLimitGB') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -MemLimitGB $MemLimitGB
    }
    if($PSBoundParameters.ContainsKey('MemReservationGB') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -MemReservationGB $MemReservationGB
    }
    if($PSBoundParameters.ContainsKey('MemSharesLevel') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -MemSharesLevel $MemSharesLevel
    }
    if($PSBoundParameters.ContainsKey('NumCpuShares') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -NumCpuShares $NumCpuShares
    }
    if($PSBoundParameters.ContainsKey('NumMemShares') -eq $true){        
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -NumMemShares $NumMemShares
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = ($Script:resConfig | Select-Object *)
    }
    else{
        Write-Output ($Script:resConfig | Select-Object *)
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