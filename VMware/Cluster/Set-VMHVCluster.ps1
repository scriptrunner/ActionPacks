#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies the configuration of a cluster

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

.Parameter ClusterID
    Specifies the ID of the cluster you want to modify

.Parameter ClusterName
    Specifies the name of the cluster you want to modify

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

.Parameter NewName
    Specifies a new name for the cluster
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
    [string]$ClusterID,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$ClusterName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("FullyAutomated", "Manual", "PartiallyAutomated")]
    [string]$DrsAutomationLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$DrsEnabled,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$HAAdmissionControlEnabled,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$HAEnabled,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateRange(1,4)]
    [int32]$HAFailoverLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("PowerOff ", "DoNothing")]
    [string]$HAIsolationResponse,    
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Disabled ", "Low","Medium","High")]
    [string]$HARestartPriority,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewName
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @('Name','Id','HATotalSlots','HAUsedSlots','HAEnabled','HASlotMemoryGB','HASlotNumVCpus')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:cluster = Get-Cluster -Server $Script:vmServer -Id $ClusterID -ErrorAction Stop
    }
    else{
        $Script:cluster = Get-Cluster -Server $Script:vmServer -Name $ClusterName -ErrorAction Stop
    }    
    if($PSBoundParameters.ContainsKey('DrsEnabled') -eq $true){
        Set-Cluster -Cluster $Script:cluster -Server $Script:vmServer -DrsEnabled $DrsEnabled -ErrorAction Stop
    }            
    if($PSBoundParameters.ContainsKey('HAAdmissionControlEnabled') -eq $true){
        Set-Cluster -Cluster $Script:cluster -Server $Script:vmServer -HAAdmissionControlEnabled $HAAdmissionControlEnabled -ErrorAction Stop
    }           
    if($PSBoundParameters.ContainsKey('HAEnabled') -eq $true){
        Set-Cluster -Cluster $Script:cluster -Server $Script:vmServer -HAEnabled $HAEnabled -ErrorAction Stop
    }       
    if($PSBoundParameters.ContainsKey('HARestartPriority') -eq $true){
        Set-Cluster -Cluster $Script:cluster -Server $Script:vmServer -HARestartPriority $HARestartPriority -ErrorAction Stop
    }            
    if($PSBoundParameters.ContainsKey('HAIsolationResponse') -eq $true){
        Set-Cluster -Cluster $Script:cluster -Server $Script:vmServer -HAIsolationResponse $HAIsolationResponse -ErrorAction Stop
    }           
    if($PSBoundParameters.ContainsKey('HAFailoverLevel') -eq $true){
        Set-Cluster -Cluster $Script:cluster -Server $Script:vmServer -HAFailoverLevel $HAFailoverLevel -ErrorAction Stop
    } 
    if($PSBoundParameters.ContainsKey('DrsAutomationLevel') -eq $true){
        Set-Cluster -Cluster $Script:cluster -Server $Script:vmServer -DrsAutomationLevel $DrsAutomationLevel -ErrorAction Stop
    } 
    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        Set-Cluster -Cluster $Script:cluster -Server $Script:vmServer -Name $NewName -ErrorAction Stop
    } 

    $result = Get-Cluster -Server $Script:vmServer -Name $Script:cluster.Name -ErrorAction Stop | Select-Object $Properties

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