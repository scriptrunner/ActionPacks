#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new virtual floppy drive

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Drives

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter VMName
        [sr-en] Virtual machine to which you want to attach the new virtual floppy drive
        [sr-de] Virtuelle Maschine

    .Parameter FloppyImagePath
        [sr-en] Datastore path to the floppy image file backing the virtual floppy drive
        [sr-de] Datastore

    .Parameter HostDevice
        [sr-en] Path to the floppy drive on the host which will back this virtual floppy drive
        [sr-de] Laufwerk

    .Parameter NewFloppyImagePath
        [sr-en] New datastore path to a floppy image file backing the virtual floppy drive
        [sr-de] Datastore Pfad des Images

    .Parameter StartConnected
        [sr-en] Virtual floppy drive starts connected when its associated virtual machine powers on
        [sr-de] Diskettenlaufwerk verbinden beim Start der virtuellen Maschine
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [string]$FloppyImagePath,
    [string]$HostDevice,
    [string]$NewFloppyImagePath,
    [switch]$StartConnected
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop

    if([System.String]::IsNullOrWhiteSpace($NewFloppyImagePath) -eq $true){
        $Script:floppy = New-FloppyDrive -Server $Script:vmServer -VM $Script:machine -StartConnected:$StartConnected -Confirm:$false -ErrorAction Stop
    }
    else {
        $Script:floppy = New-FloppyDrive -Server $Script:vmServer -VM $Script:machine -NewFloppyImagePath $NewFloppyImagePath -StartConnected:$StartConnected -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('FloppyImagePath') -eq $true){
        $null = Set-FloppyDrive -Floppy $Script:floppy -FloppyImagePath $FloppyImagePath -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HostDevice') -eq $true){
        $null = Set-FloppyDrive -Floppy $Script:floppy -HostDevice $HostDevice -Confirm:$false -ErrorAction Stop
    }
    $result = Get-FloppyDrive -Server $Script:vmServer -VM $Script:machine -ErrorAction Stop | Select-Object *

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