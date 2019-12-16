#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

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
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Drives

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VMName
    Specifies the virtual machine to which you want to attach the new virtual floppy drive

.Parameter FloppyImagePath
    Specifies the datastore path to the floppy image file backing the virtual floppy drive

.Parameter HostDevice
    Specifies the path to the floppy drive on the host which will back this virtual floppy drive

.Parameter NewFloppyImagePath
    Specifies a new datastore path to a floppy image file backing the virtual floppy drive

.Parameter StartConnected
    Indicates that the virtual floppy drive starts connected when its associated virtual machine powers on
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

Import-Module VMware.PowerCLI

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