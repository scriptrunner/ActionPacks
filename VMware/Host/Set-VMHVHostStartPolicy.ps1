#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Modifies the host default start policy

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter HostId
        [sr-en] ID of the host want to modify
        [sr-de] Id des Host

    .Parameter HostName
        [sr-en] Name of the host want to modify
        [sr-de] Hostname

    .Parameter Enabled
        [sr-en] Service that controls the host start policies is enabled
        [sr-de] Dienst der Host-Start-Richtlinie aktivieren

    .Parameter StartDelay
        [sr-en] Default start delay of the virtual machines in seconds
        [sr-de] Standard-Startverzögerung, in Sekunden

    .Parameter StopAction
        [sr-en] Default action that is applied to the virtual machines when the server stops
        [sr-de] Standardaktion beim Stoppen des Servers

    .Parameter StopDelay
        [sr-en] Default stop delay of the virtual machines in seconds
        [sr-de]Standard-Stoppverzögerung, in Sekunden

    .Parameter WaitForHeartBeat
        [sr-en] Virtual machines should start after receiving a heartbeat from the host, ignore heartbeats, 
        and start after the StartDelay has elapsed ($true), or follow the system default before powering on ($false)
        [sr-de] Virtuelle Maschinen starten nach dem Empfangen des Signals
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
    [string]$HostId,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$HostName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$Enabled,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StartDelay,    
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("None","Suspend","PowerOff","GuestShutdown")]
    [string]$StopAction,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$StopDelay,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$WaitForHeartBeat
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:vmhost = Get-VMHost -Server $Script:vmServer -Id $HostId -ErrorAction Stop
    }
    else{
        $Script:vmhost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    }

    $poli = Get-VMHostStartPolicy -Server $Script:vmServer -VMHost $Script:vmhost -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'VMHostStartPolicy' = $poli
                            'Confirm' = $false
                            }                            

    Set-VMHostStartPolicy @cmdArgs -Enabled $Enabled
    if($StartDelay -gt 0){
        Set-VMHostStartPolicy @cmdArgs -StartDelay $StartDelay
    }
    if($StopDelay -gt 0){
        Set-VMHostStartPolicy @cmdArgs -StopDelay $StopDelay
    }    
    if($PSBoundParameters.ContainsKey('StopAction') -eq $true){
        Set-VMHostStartPolicy @cmdArgs -StopAction $StopAction
    }
    if($PSBoundParameters.ContainsKey('WaitForHeartBeat') -eq $true){
        Set-VMHostStartPolicy @cmdArgs -WaitForHeartBeat $WaitForHeartBeat
    }

    $result = Get-VMHostStartPolicy -Server $Script:vmServer -VMHost $Script:vmhost -ErrorAction Stop | Select-Object *

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