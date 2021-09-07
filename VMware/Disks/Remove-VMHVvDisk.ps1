#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Storage

<#
.SYNOPSIS
    Removes VDisk objects and the associated backings from the datastore

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

.Parameter DiskID
    [sr-en] ID of the VDisk
    [sr-de] ID der vDisk
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
    [string]$DiskName
)

Import-Module VMware.VimAutomation.Storage

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
    }
    if($PSCmdlet.ParameterSetName  -eq "ById"){
        $cmdArgs.Add('Id', $DiskID)
    }
    else {
        $cmdArgs.Add('Name', $DiskName)
    }
    $disk = Get-VDisk @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'VDisk' = $disk
                'Confirm' = $false
                } 
    
    $null = Remove-VDisk @cmdArgs

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "VDisk successful removed"
    }
    else{
        Write-Output "VDisk successful removed"
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