#Requires -Version 4.0

<#
.SYNOPSIS
    Optimizes a volume

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    
.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/Disks

.Parameter DriveLetter
    Specifies a letter used to identify a drive or volume in the system

.Parameter Analyze
    Analyzes the volume specified for fragmentation statistics. Performs analysis only and reports the current optimization state of the volume

.Parameter Defrag
    Indicates that the cmdlet initiates defragmentation on the specified volume. Defragmentation consolidates fragmented regions of files to improve performance of sequential reads or writes

.Parameter ReTrim
    Generates TRIM and Unmap hints for all currently unused sectors of the volume, notifying the underlying storage that the sectors are no longer needed and can be purged. This can recover unused capacity on thinly provisioned drives

.Parameter SlabConsolidate
    Indicates that the cmdlet performs slab consolidation on the storage to optimize slab allocations and to reduce the number of used slabs

.Parameter TierOptimize
    Indicates that the cmdlet performs tier optimization of the volume, which places file data on the optimal storage tier according to heat or desired placement. This parameter only applies to tiered spaces volumes with more than one storage tier

.Parameter ComputerName
    Specifies the name of the computer from which to repair the volume object. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(    
    [Parameter(Mandatory = $true)]
    [string]$DriveLetter,
    [switch]$Analyze,
    [switch]$Defrag,
    [switch]$ReTrim,
    [switch]$SlabConsolidate,
    [switch]$TierOptimize,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
[string[]]$Script:Properties = @("DriveLetter","DriveType","HealthStatus","FileSystemType","AllocationUnitSize","Size","SizeRemaining","FileSystemLabel")

try{
    if($DriveLetter.Length -gt 0){
        $DriveLetter = $DriveLetter.Substring(0,1)        
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }        
    $Script:vol = Get-Volume -CimSession $Script:Cim -DriveLetter $DriveLetter -ErrorAction Stop
    $null = Optimize-Volume -InputObject $Script:vol -ReTrim:$ReTrim -Analyze:$Analyze -Defrag:$Defrag -SlabConsolidate:$SlabConsolidate -TierOptimize:$TierOptimize -ErrorAction Stop

    $result = Get-Volume -CimSession $Script:Cim -DriveLetter $DriveLetter | Select-Object $Script:Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage =$result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}