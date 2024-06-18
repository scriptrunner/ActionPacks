#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new hard disk on the specified location

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
        [sr-en] Name of the virtual machine to which you want to add the new disk
        [sr-de] Virtuelle Maschine

    .Parameter DatastoreName
        [sr-en] Datastore
        [sr-de] Datastore

    .Parameter CapacityGB
        [sr-en] Capacity of the new virtual disk in gigabytes (GB). 
        You need to specify this parameter when you create hard disks of type Flat
        [sr-de] Größe der Festplatte, in Gigabyte

    .Parameter SCSIControllerName
        [sr-en] SCSI controller to which you want to attach the new hard disk
        [sr-de] SCSI-Kontroller

    .Parameter DiskPath
        [sr-en] Path to the hard disk
        [sr-de] Pfad der Festplatte

    .Parameter StorageFormat
        [sr-en] Storage format of the relocated hard disk
        [sr-de] Format der vwerlagerten Festplatte

    .Parameter Persistence
        [sr-en] Disk persistence mode
        [sr-de] Festplatten Persistenz-Modus

    .Parameter DiskType
        [sr-en] Type of file backing you want to use
        [sr-de] Typ der Dateisicherung
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "CreateNew")]
    [Parameter(Mandatory = $true,ParameterSetName = "UseExisting")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "CreateNew")]
    [Parameter(Mandatory = $true,ParameterSetName = "UseExisting")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "CreateNew")]
    [Parameter(Mandatory = $true,ParameterSetName = "UseExisting")]
    [string]$VMName,    
    [Parameter(Mandatory = $true,ParameterSetName = "UseExisting")]
    [string]$DiskPath,    
    [Parameter(ParameterSetName = "CreateNew")]
    [string]$DatastoreName,
    [Parameter(ParameterSetName = "CreateNew")]
    [decimal]$CapacityGB,
    [Parameter(ParameterSetName = "CreateNew")]
    [Parameter(ParameterSetName = "UseExisting")]
    [string]$SCSIControllerName,
    [Parameter(ParameterSetName = "CreateNew")]
    [Parameter(ParameterSetName = "UseExisting")]
    [Validateset("Persistent", "NonPersistent", "IndependentPersistent", "IndependentNonPersistent", "Undoable")]
    [string]$Persistence,
    [Parameter(ParameterSetName = "CreateNew")]
    [ValidateSet("rawVirtual", "rawPhysical", "flat","unknown")]
    [string]$DiskType,
    [Parameter(ParameterSetName = "CreateNew")]
    [ValidateSet("Thin", "Thick", "EagerZeroedThick")]
    [string]$StorageFormat = "Thick"

)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:vm = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    if($PSCmdlet.ParameterSetName  -eq "UseExisting"){
        $Script:harddisk = New-HardDisk -Server $Script:vmServer -VM $Script:vm -DiskPath $DiskPath -Confirm:$false -ErrorAction Stop
    }
    else {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            }  
        if([System.String]::IsNullOrWhiteSpace($DatastoreName) -eq $false){
            $store = Get-Datastore @cmdArgs -Name $DatastoreName 
            $cmdArgs.Add('Datastore', $store)                                    
        }        
        $cmdArgs.Add('VM', $Script:vm)
        $cmdArgs.Add('StorageFormat', $StorageFormat)
        $cmdArgs.Add('Confirm', $false)
        if($CapacityGB -gt 0){
            if([System.String]::IsNullOrWhiteSpace($DiskType) -eq $true){
                $DiskType = "flat"
            }
            $cmdArgs.Add('CapacityGB', $CapacityGB)
            $cmdArgs.Add('DiskType', $DiskType)
        }
        $Script:harddisk = New-HardDisk @cmdArgs
    }
    if($PSBoundParameters.ContainsKey('SCSIControllerName') -eq $true){
        $controller = Get-ScsiController -Server $Script:vmServer -VM $Script:vm -Name $SCSIControllerName -ErrorAction Stop
        $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -Controller $controller -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('Persistence') -eq $true){
        $Script:harddisk = Set-HardDisk -HardDisk $Script:harddisk -Persistence $Persistence -Confirm:$false -ErrorAction Stop
    }
    
    $Script:Output = $Script:harddisk | Select-Object *
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
    if($null -ne $Script:vmServer) {
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}