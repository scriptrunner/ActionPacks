#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Move the virtual machine to another location

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

    .Parameter VMName
        [sr-en] Name of the virtual machine
        [sr-de] Name der VM

    .Parameter DatastoreName
        [sr-en] Datastore where you want to move the virtual machine
        [sr-de] Ziel-Datastore

    .Parameter FolderName
        [sr-en] Folder where you want to move the virtual machine
        [sr-de] Ziel-Ordner

    .Parameter DatacenterName
        [sr-en] Datacenter where you want to move the virtual machine
        [sr-de] Ziel Datacenter

    .Parameter ResourcePoolName
        [sr-en] Resource pool where you want to move the virtual machine
        [sr-de] Ziel-Resource Pool

    .Parameter HostName
        [sr-en] Host where you want to move the virtual machine
        [sr-de] Ziel-Host

    .Parameter DiskStorageFormat
        [sr-en] New storage format for the hard disk of the virtual machine you want to move
        [sr-de] Neues Festplattenformat
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "toDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "toDatacenter")]
    [Parameter(Mandatory = $true,ParameterSetName = "toFolder")]
    [Parameter(Mandatory = $true,ParameterSetName = "toHost")]
    [Parameter(Mandatory = $true,ParameterSetName = "toResourcePool")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "toDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "toDatacenter")]
    [Parameter(Mandatory = $true,ParameterSetName = "toFolder")]
    [Parameter(Mandatory = $true,ParameterSetName = "toHost")]
    [Parameter(Mandatory = $true,ParameterSetName = "toResourcePool")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "toDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "toDatacenter")]
    [Parameter(Mandatory = $true,ParameterSetName = "toFolder")]
    [Parameter(Mandatory = $true,ParameterSetName = "toHost")]
    [Parameter(Mandatory = $true,ParameterSetName = "toResourcePool")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "toDatastore")]
    [string]$DatastoreName,    
    [Parameter(Mandatory = $true,ParameterSetName = "toDatacenter")]
    [string]$DatacenterName,
    [Parameter(Mandatory = $true,ParameterSetName = "toFolder")]
    [string]$FolderName,
    [Parameter(Mandatory = $true,ParameterSetName = "toHost")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "toResourcePool")]
    [string]$ResourcePoolName,
    [Parameter(ParameterSetName = "toDatastore")]
    [ValidateSet("Thin", "Thick","EagerZeroedThick")]
    [string]$DiskStorageFormat = "Thick"
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('Name','Id','PowerState','NumCpu','Notes','Guest','GuestId','MemoryMB','UsedSpaceGB','ProvisionedSpaceGB','Folder')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'VM' = $Script:machine
                            'Confirm' = $false
                            }

    if($PSCmdlet.ParameterSetName  -eq "toFolder"){
        $folder = Get-Folder -Server $Script:vmServer -Name $FolderName -Type VM -ErrorAction Stop 
        $cmdArgs.Add('InventoryLocation', $folder)
    }
    if($PSCmdlet.ParameterSetName  -eq "toDatacenter"){
        $center = Get-Datacenter -Server $Script:vmServer -Name $DatacenterName -ErrorAction Stop 
        $cmdArgs.Add('InventoryLocation', $center)
    }
    if($PSCmdlet.ParameterSetName  -eq "toHost"){
        $Script:destination = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
        $cmdArgs.Add('Destination',  $Script:destination)
    }
    if($PSCmdlet.ParameterSetName  -eq "toResourcePool"){
        $Script:destination = Get-ResourcePool -Server $Script:vmServer -Name $ResourcePoolName -ErrorAction Stop
        $cmdArgs.Add('Destination',  $Script:destination)
    }
    if($PSCmdlet.ParameterSetName  -eq "toDatastore"){
        $store = Get-Datastore -Server $Script:vmServer -Name $DatastoreName -ErrorAction Stop
        $cmdArgs.Add('Datastore', $store)
        $cmdArgs.Add('DiskStorageFormat', $DiskStorageFormat)
    }
    $result = Move-VM @cmdArgs | Select-Object $Properties
    
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