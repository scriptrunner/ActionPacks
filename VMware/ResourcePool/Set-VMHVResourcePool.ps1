#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies a resource pool

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/ResourcePool

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter Name
    Specifies the name of the resource pool you want to Modify

.Parameter NewName
    Specifies the new name for the resource pool

.Parameter CpuExpandableReservation
    Indicates that the CPU reservation can grow beyond the specified value if the parent resource pool has unreserved resources

.Parameter CpuLimitMhz
    Specifies a CPU usage limit in MHz

.Parameter CpuReservationMhz
    Specifies the CPU size in MHz that is guaranteed to be available

.Parameter CpuSharesLevel
    Specifies the CPU allocation level for this pool

.Parameter MemExpandableReservation
    If the value is $true, the memory reservation can grow beyond the specified value if the parent resource pool has unreserved resources

.Parameter MemLimitGB
    Specifies a memory usage limit in gigabytes (GB)

.Parameter MemReservationGB
    Specifies the guaranteed available memory in gigabytes (GB)

.Parameter MemSharesLevel
    Specifies the memory allocation level for this pool

.Parameter NumCpuShares
    Specifies the CPU allocation level for this pool

.Parameter NumMemShares
    Specifies the memory allocation level for this pool

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [bool]$CpuExpandableReservation,
    [int64]$CpuLimitMhz,
    [int64]$CpuReservationMhz,
    [ValidateSet("Custom", "High", "Low","Normal")]
    [string]$CpuSharesLevel,
    [string]$NewName,
    [bool]$MemExpandableReservation,
    [decimal]$MemLimitGB,
    [decimal]$MemReservationGB,
    [ValidateSet("Custom", "High", "Low","Normal")]
    [string]$MemSharesLevel,
    [int32]$NumCpuShares,
    [int32]$NumMemShares
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:pool = Get-ResourcePool -Server $Script:vmServer -Name $Name -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'ResourcePool' = $Script:pool
                            'Confirm' = $false
                            }                            
    if($PSBoundParameters.ContainsKey('CpuExpandableReservation') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -CpuExpandableReservation $CpuExpandableReservation
    }
    if($PSBoundParameters.ContainsKey('CpuLimitMhz') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -CpuLimitMhz $CpuLimitMhz
    }
    if($PSBoundParameters.ContainsKey('CpuReservationMhz') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -CpuReservationMhz $CpuReservationMhz
    }
    if($PSBoundParameters.ContainsKey('CpuSharesLevel') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -CpuSharesLevel $CpuSharesLevel
    }
    if($PSBoundParameters.ContainsKey('MemExpandableReservation') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -MemExpandableReservation $MemExpandableReservation
    }
    if($PSBoundParameters.ContainsKey('MemLimitGB') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -MemLimitGB $MemLimitGB
    }
    if($PSBoundParameters.ContainsKey('MemReservationGB') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -MemReservationGB $MemReservationGB
    }
    if($PSBoundParameters.ContainsKey('MemSharesLevel') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -MemSharesLevel $MemSharesLevel
    }
    if($PSBoundParameters.ContainsKey('NumCpuShares') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -NumCpuShares $NumCpuShares
    }
    if($PSBoundParameters.ContainsKey('NumMemShares') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -NumMemShares $NumMemShares
    }
    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -Name $NewName
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:pool | Select-Object * 
    }
    else{
        Write-Output $Script:pool | Select-Object *
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