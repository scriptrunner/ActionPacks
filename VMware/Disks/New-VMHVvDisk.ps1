#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Storage

<#
.SYNOPSIS
    Creates a managed VDisk object

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.VimAutomation.Storage

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Disks

.Parameter VIServer
    [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
    [sr-de] IP Adresse oder Name des vSphere Servers

.Parameter VICredential
    [sr-en] PSCredential object that contains credentials for authenticating with the server
    [sr-de] Benutzerkonto um diese Aktion durchzuführen

.Parameter DiskName
    [sr-en] Name of the VDisk
    [sr-de] Name der vDisk

.Parameter Datastore
    [sr-en] Datastore on which store the metadata of the VDisk object
    [sr-de] Datastore der vDisk

.Parameter DiskType
    [sr-en] Type of the newly created VDisk object
    [sr-de] Typ der neuen vDisk

.Parameter CapacityGB
    [sr-en] Capacity of the VDisk object in gigabytes (GB)
    [sr-de] Größe der vDisk in Gigabytes (GB)

.Parameter StorageFormat
    [sr-en] Storage format of the flat VDisk object
    [sr-de] Speicherformat der vDisk

.Parameter HardDiskId
    [sr-en] ID of the hard disk
    [sr-de] ID der Hard Disk
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$DiskName,
    [Parameter(Mandatory = $true)]
    [string]$Datastore,
    [Parameter(Mandatory = $true)]
    [decimal]$CapacityGB,
    [ValidateSet('Flat','PMem','RawPhysical','RawVirtual')]
    [string]$DiskType,
    [ValidateSet('EagerZeroedThick','Thick','Thin')]
    [string]$StorageFormat<#,
    [Parameter(ParameterSetName = "RegisterVDisk")]
    [string]$HardDisk#>
)

Import-Module VMware.VimAutomation.Storage

try{
    [string[]]$Properties = @('Name','Id','CapacityGB','Datastore','StorageFormat','DiskType')    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'Datastore' = $Datastore
                            'Name' = $DiskName
                            'Confirm' = $false
    } 
    
   # if($PSCmdlet.ParameterSetName -eq 'FlatVDisk'){
        $cmdArgs.Add('CapacityGB', $CapacityGB)
        if($PSBoundParameters.ContainsKey('StorageFormat') -eq $true){
            $cmdArgs.Add('StorageFormat', $StorageFormat)
        }
 #   }
    if($PSBoundParameters.ContainsKey('DiskType') -eq $true){
        $cmdArgs.Add('DiskType', $DiskType)
    }
    $result = New-VDisk @cmdArgs | Select-Object $Properties

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