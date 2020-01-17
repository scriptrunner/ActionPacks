#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new datastore

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Datastore

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter HostName
    Specifies the name of a host where you want to create the new datastore

.Parameter StoreName
    Specifies a name for the new datastore

.Parameter Path
    If you want to create an NFS datastore, specify the remote path of the NFS mount point. 
    If you want to create a VMFS datastore, specify the canonical name of the SCSI logical unit that will contain new VMFS datastores

.Parameter FileSystemVersion
    Specifies the file system you want to use on the new datastore

.Parameter BlockSizeMB
    Specifies the maximum file size of VMFS in megabytes (MB)

.Parameter NfsHost
    Specifies the NFS host where you want to create the new datastore

.Parameter Kerberos
    By default, NFS datastores are created with AUTH_SYS as the authentication protocol. 
    This parameter indicates that the NFS datastore uses Kerberos version 5 for authentication

.Parameter ReadOnly
    Indicates that the access mode for the mount point is ReadOnly
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Vmfs")]
    [Parameter(Mandatory = $true,ParameterSetName = "Nfs")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Vmfs")]
    [Parameter(Mandatory = $true,ParameterSetName = "Nfs")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Vmfs")]
    [Parameter(Mandatory = $true,ParameterSetName = "Nfs")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Vmfs")]
    [Parameter(Mandatory = $true,ParameterSetName = "Nfs")]
    [string]$StoreName,
    [Parameter(Mandatory = $true,ParameterSetName = "Nfs")]
    [string]$NfsHost, 
    [Parameter(Mandatory = $true,ParameterSetName = "Nfs")]
    [Parameter(Mandatory = $true,ParameterSetName = "Vmfs")]
    [string]$Path,
    [Parameter(ParameterSetName = "Vmfs")]
    [Parameter(ParameterSetName = "Nfs")]
    [string]$FileSystemVersion,
    [Parameter(ParameterSetName = "Vmfs")]
    [int32]$BlockSizeMB, 
    [Parameter(ParameterSetName = "Nfs")]
    [switch]$Kerberos,
    [Parameter(ParameterSetName = "Nfs")]
    [switch]$ReadOnly
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'VMHost' = $vmHost
                            'Name' = $StoreName
                            'Path' = $Path
                            }

    if([System.String]::IsNullOrWhiteSpace($FileSystemVersion) -eq $false){
        $cmdArgs.Add('FileSystemVersion', $FileSystemVersion)
    }                            
    if($PSCmdlet.ParameterSetName  -eq "Vmfs"){
        $cmdArgs.Add('BlockSizeMB', $BlockSizeMB)
        $cmdArgs.Add('Vmfs', $null)
    }
    else {
        $cmdArgs.Add('Nfs', $null)
        $cmdArgs.Add('NfsHost', $NfsHost)
        $cmdArgs.Add('Kerberos', $Kerberos)
        $cmdArgs.Add('ReadOnly',$ReadOnly)
    }
    New-Datastore @cmdArgs
    [string[]]$Properties = @('Name','State','CapacityGB','FreeSpaceGB','Datacenter')
    $Script:Output = Get-Datastore -Server $Script:vmServer -Refresh:$RefreshFirst -Name $StoreName -ErrorAction Stop | Select-Object $Properties

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