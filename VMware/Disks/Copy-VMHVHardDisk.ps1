#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Copies a virtual hard disk to another destination

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Disks

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter VMName
        [sr-en] Virtual machine from which you want to retrieve the hard disks
        [sr-de] Virtuelle Maschine

    .Parameter TemplateName
        [sr-en] Virtual machine template from which you want to retrieve the hard disks
        [sr-de] Vorlage

    .Parameter SnapshotName
        [sr-en] Snapshot from which you want to retrieve the hard disks
        [sr-de] Snapshotname

    .Parameter DatastoreName
        [sr-en] Name of the datastore where you want to copy the hard disk
        [sr-de] Datastore 

    .Parameter DiskName
        [sr-en] Name of the SCSI hard disk you want to copy
        [sr-de] Festplatten-Name

    .Parameter DiskID
        [sr-en] ID of the hard disk you want to copy
        [sr-de] Id der Festplatte
        
    .Parameter DestinationPath
        [sr-en] Path to the folder where you want to copy the hard disk
        [sr-en] Ordnerpfad

    .Parameter DestinationStorageFormat
        [sr-en] Type of the hard disk copy
        [sr-en] Typ der Festplatte
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
    [Parameter(Mandatory = $true,ParameterSetName = "VM")]
    [Parameter(Mandatory = $true,ParameterSetName = "Template")]
    [Parameter(Mandatory = $true,ParameterSetName = "Snapshot")]
    [string]$DatastoreName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$DiskName,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$DiskID,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [string]$DestinationPath,
    [Parameter(ParameterSetName = "VM")]
    [Parameter(ParameterSetName = "Template")]
    [Parameter(ParameterSetName = "Snapshot")]
    [ValidateSet("Thin", "Thick", "EagerZeroedThick")]
    [string]$DestinationStorageFormat = "Thick"
)

Import-Module VMware.VimAutomation.Core

try{
    if([System.String]::IsNullOrWhiteSpace($DiskName) -eq $true){
        $DiskName = "*"
    }
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
    if([System.String]::IsNullOrWhiteSpace($DiskID) -eq $true){
        $cmdArgs.Add('Name', $DiskName)
    }
    else {
        $cmdArgs.Add('Id', $DiskID)
    }

    $Script:harddisk = Get-HardDisk -Server $Script:vmServer -VM $vm -Id $DiskID -ErrorAction Stop

    if([System.String]::IsNullOrWhiteSpace($DestinationPath) -eq $true){
        $DestinationPath = "[$($DatastoreName)]/"
    }
    else {
        $DestinationPath = "[$($DatastoreName)] $($DestinationPath)"   
    }
    $Script:Output = Copy-HardDisk -HardDisk $Script:harddisk -DestinationPath $DestinationPath -Force:$True `
                -DestinationStorageFormat $DestinationStorageFormat -Confirm:$false -ErrorAction Stop | Select-Object *

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