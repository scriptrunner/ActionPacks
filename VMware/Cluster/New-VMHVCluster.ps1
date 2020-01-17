#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new cluster

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Cluster

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter ClusterName
    Specifies a name for the new cluster

.Parameter LocationName
    Specifies a datacenter name or folder name where you want to place the host

.Parameter DrsAutomationLevel
    Specifies a DRS (Distributed Resource Scheduler) automation level

.Parameter DrsEnabled
    Indicates that VMware DRS (Distributed Resource Scheduler) is enabled

.Parameter HAAdmissionControlEnabled
    Indicates that the virtual machines in the cluster will not start if they violate availability constraints

.Parameter HAEnabled
    Indicates that VMware High Availability is enabled

.Parameter HAFailoverLevel
    Specifies a failover level

.Parameter HAIsolationResponse
    Specifies whether the virtual machine should be powered off if a host determines that it is isolated from the rest of the compute resource

.Parameter HARestartPriority
    Specifies the cluster HA restart priority
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$ClusterName,
    [Parameter(Mandatory = $true)]
    [string]$LocationName,
    [ValidateSet("FullyAutomated", "Manual", "PartiallyAutomated")]
    [string]$DrsAutomationLevel,
    [switch]$DrsEnabled,
    [switch]$HAAdmissionControlEnabled,
    [switch]$HAEnabled,
    [ValidateRange(1,4)]
    [int32]$HAFailoverLevel,
    [ValidateSet("PowerOff ", "DoNothing")]
    [string]$HAIsolationResponse,    
    [ValidateSet("Disabled ", "Low","Medium","High")]
    [string]$HARestartPriority
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @('Name','Id','HATotalSlots','HAUsedSlots','HAEnabled','HASlotMemoryGB','HASlotNumVCpus')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:location = Get-Folder -Server $Script:vmServer -Name $LocationName -ErrorAction Stop
    if($null -eq $Script:location){
        throw "Location $($LocationName) not found"
    }
    $null = New-Cluster -Name $ClusterName -Location $Script:location -Server $VIServer -HAAdmissionControlEnabled:$HAAdmissionControlEnabled `
                -HAEnabled:$HAEnabled -DrsEnabled:$DrsEnabled -ErrorAction Stop
    $script:cluster = Get-Cluster -Server $Script:vmServer -Name $ClusterName -ErrorAction Stop
    if($PSBoundParameters.ContainsKey('HARestartPriority') -eq $true){
        Set-Cluster -Cluster $script:cluster -Server $Script:vmServer -HARestartPriority $HARestartPriority -ErrorAction Stop
    }            
    if($PSBoundParameters.ContainsKey('HAIsolationResponse') -eq $true){
        Set-Cluster -Cluster $script:cluster -Server $Script:vmServer -HAIsolationResponse $HAIsolationResponse -ErrorAction Stop
    }           
    if($PSBoundParameters.ContainsKey('HAFailoverLevel') -eq $true){
        Set-Cluster -Cluster $script:cluster -Server $Script:vmServer -HAFailoverLevel $HAFailoverLevel -ErrorAction Stop
    }   
    if($PSBoundParameters.ContainsKey('DrsAutomationLevel') -eq $true){
        Set-Cluster -Cluster $script:cluster -Server $Script:vmServer -DrsAutomationLevel $DrsAutomationLevel -ErrorAction Stop
    } 

    $result = Get-Cluster -Server $Script:vmServer -Name $script:cluster.Name -ErrorAction Stop | Select-Object $Properties

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