#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Runs a script in the guest OS of the specified virtual machine

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
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter VMId
        [sr-en] ID of the virtual machine
        [sr-de] ID der VM

    .Parameter VMName
        [sr-en] Name of the virtual machine
        [sr-de] Name der VM

    .Parameter GuestCredential
        [sr-en] PSCredential object containing the credentials you want to use for authenticating with the virtual machine guest OS
        [sr-de] Benutzerkonto für das Betriebssystem

    .Parameter ScriptText
        [sr-en] Provides the text of the script you want to run
        [sr-de] Auszuführender Scriptcode

    .Parameter ScriptType
        [sr-en] Type of the script
        [sr-de] Script-Typ
        
    .Parameter ToolsWaitSecs
        [sr-en] Seconds the system to wait for connecting to the VMware Tools
        [sr-de] Wartezeit für das Verbinden der VMware Tools, in Sekunden
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
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$ScriptText,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [pscredential]$GuestCredential,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Validateset('PowerShell', 'Bat','Bash')]
    [string]$ScriptType = "PowerShell",
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$ToolsWaitSecs = 20
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }    
    if($null -eq $GuestCredential){
        $Script:Output = Invoke-VMScript -VM $Script:machine -Server $Script:vmServer -ScriptText $ScriptText -ScriptType $ScriptType `
                             -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
    }
    else {
        $Script:Output = Invoke-VMScript -VM $Script:machine -Server $Script:vmServer -ScriptText $ScriptText -ScriptType $ScriptType `
                            -GuestCredential $GuestCredential -ToolsWaitSecs $ToolsWaitSecs -Confirm:$false -ErrorAction Stop
    }

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