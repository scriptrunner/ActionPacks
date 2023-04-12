#Requires -Version 5.0
#Requires -Modules VMware.VIMAutomation.Core

<#
.SYNOPSIS
    Retrieves the properties of the virtual machines on a vCenter Server system

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires ModuleVMware.VIMAutomation.Core

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/_QUERY_

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential
)

Import-Module VMware.VIMAutomation.Core

try{    
    $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $machines = Get-VM -Server $vmServer -ErrorAction Stop | Select-Object Id,Name,Notes,NumCpu,MemoryGB,CoresPerSocket | Sort-Object Name

    foreach($item in $machines){
        $disk = Get-VM -Server $vmServer -ErrorAction Stop -Id $item.Id | Get-VMGuestDisk
        $stats = Get-VM -Server $vmServer -ErrorAction Stop -Id $item.Id | Get-Stat -Stat @('mem.usage.average','cpu.usage.average') -MaxSamples 1 -Start (Get-Date)
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add(@{Id = $item.Id
                                             Name = $item.Name   
                                             Notes = $item.Notes
                                             Cpus = $item.NumCpu
                                             CoresPerSocket = $item.CoresPerSocket
                                             Memory = $item.MemoryGB
                                             GuestDiskTotal = [System.Math]::Round(($disk.CapacityGB | Measure-Object -Sum).Sum,3)
                                             GuestDiskFree = [System.Math]::Round(($disk.FreeSpaceGB | Measure-Object -Sum).Sum,3)
                                             'MemoryUsageAverage' = "$(($stats | Where-Object {$_.MetricID -eq 'mem.usage.average'}).Value) %"
                                             'CpuUsageAverage' = "$(($stats | Where-Object {$_.MetricID -eq 'cpu.usage.average'}).Value) %"

            })
            $null = $SRXEnv.ResultList2.Add($item.Name) # Display
        }
        else{
            Write-Output "$($item.Name) - $($item.Notes)"
        }
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