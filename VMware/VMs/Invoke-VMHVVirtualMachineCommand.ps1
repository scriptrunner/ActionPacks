#Requires -Version 5.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Invokes a command for the specified virtual machine. 
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

.Parameter VIServer
    [sr-en] Specifies the IP address or the DNS name of the vSphere server to which you want to connect
    [sr-de] IP-Adresse oder der DNS-Name des vSphere-Servers

.Parameter VICredential
    [sr-en] Specifies a PSCredential object that contains credentials for authenticating with the server
    [sr-de] Benutzerkonto für die Authentifizierung beim Server

.Parameter VMId
    [sr-en] Specifies the ID of the virtual machine you want to execute the command
    [sr-de] ID der virtuellen Maschine

.Parameter VMName
    [sr-en] Specifies the name of the virtual machine you want to execute the command
    [sr-de] Name der virtuellen Maschine

.Parameter Command
    [sr-en] Specifies the command that executed on the virtual machine
    [sr-de] Befehl, der auf der virtuellen Maschine ausgeführt wird

.Parameter Kill
    [sr-en] Indicates that you want to stop the specified virtual machine by terminating the processes running on the ESX
    [sr-de] Die auf dem ESX-System laufenden Prozesse beenden
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
    [Parameter(ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [ValidateSet('Start','Stop','Suspend','Restart')]
    [string]$Command = 'Restart',
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$Kill
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byName"){
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }

    switch($Command){
        "Start"{
            $null = Start-VM -VM $Script:machine -Server $Script:vmServer -Confirm:$false -ErrorAction Stop
        }
        "Stop"{
            $null = Stop-VM -VM $Script:machine -Server $Script:vmServer -Kill:$Kill -Confirm:$false -ErrorAction Stop
        }
        "Suspend"{
            $null = Suspend-VM -VM $Script:machine -Server $Script:vmServer -Confirm:$false -ErrorAction Stop
        }
        "Restart"{
            $null = Restart-VM -VM $Script:machine -Server $Script:vmServer -Confirm:$false -ErrorAction Stop
        }
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Command $($Command) successfully executed on the virtual machine $($Script:machine.Name)"
    }
    else{
        Write-Output "Command $($Command) successfully executed on the virtual machine $($Script:machine.Name)"
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