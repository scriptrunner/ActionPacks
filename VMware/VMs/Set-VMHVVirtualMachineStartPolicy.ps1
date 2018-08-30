#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies the virtual machine start policy

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VMs

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMId
    Specifies the ID of the virtual machine you want to retrieve

.Parameter VMName
    Specifies the name of the virtual machine you want to retrieve, is the parameter empty all virtual machines retrieved

.Parameter StartAction
    Indicates that the virtual machine uses the value of the StartDelay parameter of the host

.Parameter StopAction
    Specifies the default action of the virtual machine when the server stops

.Parameter StartDelay
    Specifies a default start delay in seconds

.Parameter StopDelay
    Specifies a default stop delay in seconds

.Parameter StartOrder
    Specifies a number to define the virtual machines start order

.Parameter UnspecifiedStartOrder
    Indicates that no order is defined for starting the virtual machines

.Parameter WaitForHeartBeat
    Indicates whether the virtual machine should start after receiving a heartbeat, ignore heartbeats and start after the StartDelay has elapsed ($true), 
    or follow the system default before powering on ($false)

.Parameter InheritStartDelayFromHost
    Indicates that the virtual machine uses the value of the StartDelay parameter of the host

.Parameter InheritStopActionFromHost
    Indicates that the virtual machine uses the value of the StopAction parameter of the host

.Parameter InheritStopDelayFromHost
    Indicates that the virtual machine uses the value of the StopDelay parameter of the host

.Parameter InheritWaitForHeartbeatFromHost
    Indicates that the virtual machine uses the value of the WaitforHeartbeat parameter of the host
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
    [ValidateSet("None","PowerOn")]
    [string]$StartAction = "None",
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StartDelay,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StartOrder,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("None","Suspend","PowerOff","GuestShutdown")]
    [string]$StopAction = "None",
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StopDelay,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$InheritStartDelayFromHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$InheritStopActionFromHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$InheritStopDelayFromHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$InheritWaitForHeartbeatFromHost,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$UnspecifiedStartOrder,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$WaitForHeartBeat
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @("VirtualMachineName","StartAction","StartDelay","StopAction","StopDelay","IsStartDelayInherited","IsStopActionInherited","IsStopDelayInherited","IsWaitForHeartbeatInherited")
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }
    
    $Script:poli = Get-VMStartPolicy -Server $Script:vmServer -VM $Script:machine -ErrorAction Stop
    if($StartDelay -gt 0){
        Set-VMStartPolicy -StartPolicy $Script:poli -StartDelay $StartDelay -Confirm:$false -ErrorAction Stop
    }
    if($StopDelay -gt 0){
        Set-VMStartPolicy -StartPolicy $Script:poli -StopDelay $StopDelay -Confirm:$false -ErrorAction Stop
    }
    if($StartOrder -gt 0){
        Set-VMStartPolicy -StartPolicy $Script:poli -StartOrder $StartOrder -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('StartAction') -eq $true){
        Set-VMStartPolicy -StartPolicy $Script:poli -StartAction $StartAction -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('StopAction') -eq $true){
        Set-VMStartPolicy -StartPolicy $Script:poli -StopAction $StopAction -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('UnspecifiedStartOrder') -eq $true){
        Set-VMStartPolicy -StartPolicy $Script:poli -UnspecifiedStartOrder:$UnspecifiedStartOrder -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('WaitForHeartBeat') -eq $true){
        Set-VMStartPolicy -StartPolicy $Script:poli -WaitForHeartBeat $WaitForHeartBeat -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('InheritStartDelayFromHost') -eq $true){
        Set-VMStartPolicy -StartPolicy $Script:poli -InheritStartDelayFromHost:$InheritStartDelayFromHost -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('InheritStopActionFromHost') -eq $true){
        Set-VMStartPolicy -StartPolicy $Script:poli -InheritStopActionFromHost:$InheritStopActionFromHost -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('InheritStopDelayFromHost') -eq $true){
        Set-VMStartPolicy -StartPolicy $Script:poli -InheritStopDelayFromHost:$InheritStopDelayFromHost -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('InheritWaitForHeartbeatFromHost') -eq $true){
        Set-VMStartPolicy -StartPolicy $Script:poli -InheritWaitForHeartbeatFromHost:$InheritWaitForHeartbeatFromHost -Confirm:$false -ErrorAction Stop
    }

    $Script:Output = Get-VMStartPolicy -Server $Script:vmServer -VM $Script:machine -ErrorAction Stop | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
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