#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Install VMtools on the virtual machine

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

    .Parameter GuestCredential
        [sr-en] PSCredential object containing the credentials you want to use for authenticating with the virtual machine guest OS
        [sr-de] Benutzerkonto für das Betriebssystem

    .Parameter VMId
        [sr-en] ID of the virtual machine
        [sr-de] ID der VM

    .Parameter VMName
        [sr-en] Name of the virtual machine
        [sr-de] Name der VM

    .Parameter DriveLetter
        [sr-en] Virtual CD drive with the VMware tools
        [sr-de] Laufwerksbuchstbane der VMware Tools

    .Parameter NoReboot
        [sr-en] Indicates that you do not want to reboot the system after install and updating VMware Tools
        [sr-de] System nach der Installation und Aktualisierung der VMware Tools nicht neu starten
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
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [pscredential]$GuestCredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$DriveLetter,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$NoReboot
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('OSFullName','State','IPAddress','Disks','ConfiguredGuestId','ToolsVersion')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }
    
    Mount-Tools -VM $Script:machine -Server $Script:vmServer -ErrorAction SilentlyContinue
    Invoke-Command -ComputerName $Script:machine.Name -Credential $GuestCredential -Scriptblock {
        "$($Using:DriveLetter):\setup.exe /s /v ""/qn reboot=r"""
    } 
    Update-Tools -VM $Script:machine -Server $Script:vmServer -NoReboot:$NoReboot -ErrorAction Stop `
            | Wait-Tools -ErrorAction Stop

    Dismount-Tools -VM $Script:machine -Server $Script:vmServer -ErrorAction Stop

    $result = Get-VMGuest -VM $Script:machine -Server $Script:vmServer -ErrorAction Stop `
                    | Select-Object $Properties

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