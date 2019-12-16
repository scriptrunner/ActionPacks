#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new virtual CD drive

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

.Parameter HostDevice
    Specifies the path to the CD drive on the virtual machine host that backs the virtual CD drive

.Parameter IsoPath
    Specifies the datastore path to the ISO (CD image) file that backs the virtual CD drive

.Parameter StartConnected
    Indicates that the virtual CD drive starts connected when the virtual machine associated with it powers on
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [string]$HostDevice,
    [string]$IsoPath,
    [switch]$StartConnected
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop

    $Script:drive = New-CDDrive -Server $Script:vmServer -VM $Script:machine -StartConnected:$StartConnected -Confirm:$false -ErrorAction Stop
    
    if($PSBoundParameters.ContainsKey('IsoPath') -eq $true){
        $null = Set-CDDrive -CD $Script:drive -IsoPath $IsoPath -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HostDevice') -eq $true){
        $null = Set-CDDrive -CD $Script:drive -HostDevice $HostDevice -Confirm:$false -ErrorAction Stop
    }
    $result = Get-CDDrive -Server $Script:vmServer -VM $Script:machine -ErrorAction Stop | Select-Object *

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