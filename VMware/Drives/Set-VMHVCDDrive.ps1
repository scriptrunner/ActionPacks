#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies the configuration of the specified virtual CD drive

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

.Parameter DriveName
    Specifies the name of the CD drive you want to retrieve

.Parameter VMName
    Specifies the virtual machine from which you want to configure the virtual CD drive

.Parameter TemplateName
    Specifies the virtual machine template from which you want to configure the virtual CD drive

.Parameter SnapshotName
    Specifies the snapshot from which you want to configure the virtual CD drive

.Parameter Connected
    Indicates that the virtual CD drive is connected after its creation. 
    This parameter can be specified only if the corresponding virtual machine is powered on    

.Parameter NoMedia
    Indicates that you want to detach from the CD drive any type of connected media - 
    ISO from datastore or host device

.Parameter HostDevice
    Specifies the path to the CD drive on the host which backs this virtual CD drive

.Parameter IsoPath
    Specifies the datastore path to the ISO (CD image) file that backs the virtual CD drive

.Parameter StartConnected
    Indicates that the virtual CD drive starts connected when the virtual machine associated with it powers on.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [pscredential]$VICredential,    
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]    
    [string]$TemplateName,
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$SnapshotName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$DriveName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$Connected,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [switch]$NoMedia,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$HostDevice,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$IsoPath,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [bool]$StartConnected
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            }                            
    if($PSCmdlet.ParameterSetName  -eq "Snapshot"){
        $vm = Get-VM @cmdArgs -Name $VMName
        $snap = Get-Snapshot @cmdArgs -Name $SnapshotName -VM $vm
        $cmdArgs.Add('Snapshot', $snap)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "Template"){
        $temp = Get-Template @cmdArgs -Name $TemplateName
        $cmdArgs.Add('Template', $temp)
    }
    else {
        $vm = Get-VM @cmdArgs -Name $VMName  
        $cmdArgs.Add('VM', $vm)
    }

    if([System.String]::IsNullOrWhiteSpace($DriveName)){
        $DriveName = "*"
    }
    $Script:drive = Get-CDDrive @cmdArgs -Name $DriveName

    if($PSBoundParameters.ContainsKey('IsoPath') -eq $true){
        $Script:drive = Set-CDDrive -CD $Script:drive -IsoPath $IsoPath -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HostDevice') -eq $true){
        $Script:drive = Set-CDDrive -CD $Script:drive -HostDevice $HostDevice -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('Connected') -eq $true){
        $Script:drive = Set-CDDrive -CD $Script:drive -Connected $Connected -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('NoMedia') -eq $true){
        $Script:drive = Set-CDDrive -CD $Script:drive -NoMedia:$NoMedia -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('StartConnected') -eq $true){
        $Script:drive = Set-CDDrive -CD $Script:drive -StartConnected $StartConnected -Confirm:$false -ErrorAction Stop
    }
    $result = $Script:drive | Select-Object *

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