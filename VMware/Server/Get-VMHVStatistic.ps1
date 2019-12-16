#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the statistical information available on a vCenter Server system

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Server

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter Common
    Indicates whether collects common CPU, disk, memory and network statistics

.Parameter CPU
    Indicates whether collects common CPU statistics, such as the average CPU usage and average CPU usagemhz counters as appropriate for each entity

.Parameter Memory
    Indicates whether collects common memory statistics, such as the mem usage, mem vmmemctl, mem active and mem granted counters as appropriate for each entity

.Parameter Disk
    Indicates whether collects common disk statistics, such as the average disk usage, average disk read and average disk write counters as appropriate for each entity

.Parameter Network
    Indicates whether collects common network statistics, such as the average network usage, average network transmitted and average network received counters as appropriate for each entity

.Parameter MaxResult
    Specifies the maximum number of statistical information, beginning with the newest, are retrieved
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [switch]$Common,
    [switch]$CPU,
    [switch]$Memory,
    [switch]$Disk,
    [switch]$Network,
    [ValidateRange(1,100)]
    [int]$MaxResult = 20
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $result = Get-Stat -Server $Script:vmServer -Common:$Common -Memory:$Memory -Cpu:$CPU `
                    -Disk:$Disk -Network:$Network -ErrorAction Stop | Select-Object -First $MaxResult

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
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}