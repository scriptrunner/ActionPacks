#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Modifies the virtual machine start policy

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VMs

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP-Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Anmeldedaten für die Authentifizierung beim Server

    .Parameter VMId
        [sr-en] ID of the virtual machine
        [sr-de] ID der VM

    .Parameter VMName
        [sr-en] Name of the virtual machine
        [sr-de] Name der VM

    .Parameter StartAction
        [sr-en] Virtual machine uses the value of the StartDelay parameter of the host
        [sr-de] Virtuelle Maschine verwendet StartDelay des Hosts

    .Parameter StopAction
        [sr-en] Default action of the virtual machine when the server stops
        [sr-de] Standardaktion der virtuellen Maschine beim SToppen des Servers

    .Parameter StartDelay
        [sr-en] Default start delay in seconds
        [sr-de] Standard-Startverzögerung in Sekunden

    .Parameter StopDelay
        [sr-en] Default stop delay in seconds
        [sr-de] Standard-Stopverzögerung in Sekunden

    .Parameter StartOrder
        [sr-en] Number to define the virtual machines start order
        [sr-de] Startreihenfolge der virtuellen Maschine

    .Parameter UnspecifiedStartOrder
        [sr-en] Indicates that no order is defined for starting the virtual machines
        [sr-de] Keine Reihenfolge für den Start der virtuellen Maschinen definiert

    .Parameter WaitForHeartBeat
        [sr-en] Indicates whether the virtual machine should start after receiving a heartbeat, ignore heartbeats and start after the StartDelay has elapsed ($true), 
        or follow the system default before powering on ($false)
        [sr-de] Virtuelle Maschine nach dem Empfang eines Heartbeats starten

    .Parameter InheritStartDelayFromHost
        [sr-en] Indicates that the virtual machine uses the value of the StartDelay parameter of the host
        [sr-de] Virtuelle Maschine verwendet den Wert des StartDelay-Parameters des Hosts

    .Parameter InheritStopActionFromHost
        [sr-en] Indicates that the virtual machine uses the value of the StopAction parameter of the host
        [sr-de] Virtuelle Maschine verwendet den Wert des StopAction-Parameters des Hosts

    .Parameter InheritStopDelayFromHost
        [sr-en] Indicates that the virtual machine uses the value of the StopDelay parameter of the host
        [sr-de] Virtuelle Maschine verwendet den Wert des StopDelay-Parameters des Hosts

    .Parameter InheritWaitForHeartbeatFromHost
        [sr-en] Indicates that the virtual machine uses the value of the WaitforHeartbeat parameter of the host
        [sr-de] Virtuelle Maschine verwendet den Wert des Parameters WaitforHeartbeat des Hosts
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

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('VirtualMachineName','StartAction','StartDelay','StopAction','StopDelay','IsStartDelayInherited','IsStopActionInherited','IsStopDelayInherited','IsWaitForHeartbeatInherited')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }
    
    $Script:poli = Get-VMStartPolicy -Server $Script:vmServer -VM $Script:machine -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'StartPolicy' = $Script:poli
                            'Confirm' = $false}

    if($StartDelay -gt 0){
        $null = Set-VMStartPolicy @cmdArgs -StartDelay $StartDelay
    }
    if($StopDelay -gt 0){
        $null = Set-VMStartPolicy @cmdArgs -StopDelay $StopDelay
    }
    if($StartOrder -gt 0){
        $null = Set-VMStartPolicy @cmdArgs -StartOrder $StartOrder
    }
    if($PSBoundParameters.ContainsKey('StartAction') -eq $true){
        $null = Set-VMStartPolicy @cmdArgs -StartAction $StartAction
    }
    if($PSBoundParameters.ContainsKey('StopAction') -eq $true){
        $null = Set-VMStartPolicy @cmdArgs -StopAction $StopAction
    }
    if($PSBoundParameters.ContainsKey('UnspecifiedStartOrder') -eq $true){
        $null = Set-VMStartPolicy @cmdArgs -UnspecifiedStartOrder:$UnspecifiedStartOrder
    }
    if($PSBoundParameters.ContainsKey('WaitForHeartBeat') -eq $true){
        $null = Set-VMStartPolicy @cmdArgs -WaitForHeartBeat $WaitForHeartBeat
    }
    if($PSBoundParameters.ContainsKey('InheritStartDelayFromHost') -eq $true){
        $null = Set-VMStartPolicy @cmdArgs -InheritStartDelayFromHost:$InheritStartDelayFromHost
    }
    if($PSBoundParameters.ContainsKey('InheritStopActionFromHost') -eq $true){
        $null = Set-VMStartPolicy @cmdArgs -InheritStopActionFromHost:$InheritStopActionFromHost
    }
    if($PSBoundParameters.ContainsKey('InheritStopDelayFromHost') -eq $true){
        $null = Set-VMStartPolicy @cmdArgs -InheritStopDelayFromHost:$InheritStopDelayFromHost
    }
    if($PSBoundParameters.ContainsKey('InheritWaitForHeartbeatFromHost') -eq $true){
        $null = Set-VMStartPolicy @cmdArgs -InheritWaitForHeartbeatFromHost:$InheritWaitForHeartbeatFromHost
    }

    $result = Get-VMStartPolicy -Server $Script:vmServer -VM $Script:machine -ErrorAction Stop | Select-Object $Properties
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