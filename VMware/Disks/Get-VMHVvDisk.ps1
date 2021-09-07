#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Storage

<#
.SYNOPSIS
    Retrieves VDisk objects

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

.Parameter DatastoreName
    [sr-en] Datastore from which retrieve the VDisks
    [sr-de] Datastore der vDisks

.Parameter DiskName
    [sr-en] Name of the VDisk
    [sr-de] Name der vDisk

.Parameter DiskID
    [sr-en] ID of the VDisk
    [sr-de] ID der vDisk

.Parameter Properties
    [sr-en] List of properties to expand. Use * for all properties
    [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byId")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byId")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byId")]
    [string]$DiskID,
    [Parameter(ParameterSetName = "byName")]
    [string]$DiskName,
    [Parameter(ParameterSetName = "byName")]
    [string]$DatastoreName,
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byId")]
    [ValidateSet('*','Name','Id','CapacityGB','Datastore','StorageFormat','DiskType','Filename','ExtensionData','Uid')]
    [string[]]$Properties = @('Name','Id','CapacityGB','Datastore','StorageFormat','DiskType')
)

Import-Module VMware.VimAutomation.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            }                            
    if($PSCmdlet.ParameterSetName  -eq "ById"){
        $cmdArgs.Add('Id', $DiskID)
    }
    else {
        if($PSBoundParameters.ContainsKey('DiskName') -eq $true){
            $cmdArgs.Add('Name', $DiskName)
        }
        if($PSBoundParameters.ContainsKey('DatastoreName') -eq $true){
            $cmdArgs.Add('Datastore', $DatastoreName)
        }        
    }
    $result = Get-VDisk @cmdArgs | Select-Object $Properties
    
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