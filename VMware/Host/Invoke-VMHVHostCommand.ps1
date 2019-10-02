#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Invokes a command for the specified host. 
    The acceptable commands are: Start, Stop, Suspend, Restart

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter ID
    Specifies the ID of the host you want to execute the command

.Parameter Name
    Specifies the name of the host you want to execute the command

.Parameter Command
    Specifies the command that executed on the host

.Parameter TimeoutSeconds
    Specifies a time period in seconds to wait for a heartbeat signal from the host or 
    to wait for the host to enter standby mode

.Parameter Evacuate 
    If the value is $true, vCenter Server automatically reregisters the virtual machines that are compatible for reregistration. 
    On restart, indicates that vCenter Server automatically reregisters the virtual machines that are compatible for reregistration
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
    [string]$ID,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [ValidateSet('Start','Stop','Suspend','Restart')]
    [string]$Command,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$TimeoutSeconds = 300,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$Evacuate
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($TimeoutSeconds -le 0){
        $TimeoutSeconds = 300
    }
    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:vmHost = Get-VMHost -Server $Script:vmServer -ID $ID -ErrorAction Stop
    }
    else{
        $Script:vmHost = Get-VMHost -Server $Script:vmServer -Name $Name -ErrorAction Stop
    }
    switch($Command){
        "Start"{
            Start-VMHost -VMHost $Script:vmHost -TimeoutSeconds $TimeoutSeconds -Server $Script:vmServer -Confirm:$false -ErrorAction Stop
        }
        "Stop"{
            Stop-VMHost -VMHost $Script:vmHost -Server $Script:vmServer -Force:$true -Confirm:$false -ErrorAction Stop
        }
        "Suspend"{
            Suspend-VMHost -VMHost $Script:vmHost -TimeoutSeconds $TimeoutSeconds -Evacuate:$Evacuate -Server $Script:vmServer -Confirm:$false -ErrorAction Stop
        }
        "Restart"{
            Restart-VMHost -VMHost $Script:vmHost -Evacuate:$Evacuate -Server $Script:vmServer -Force:$true -Confirm:$false -ErrorAction Stop
        }
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Command $($Command) successfully executed on the host $($Script:vmHost.Name)"
    }
    else{
        Write-Output "Command $($Command) successfully executed on the host $($Script:vmHost.Name)"
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