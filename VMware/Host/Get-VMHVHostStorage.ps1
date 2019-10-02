#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the host storages on a vCenter Server system

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter HostName
    Specifies the hosts for which you want to retrieve storage information

.Parameter Id
    Specifies the IDs of the host storages that you want to retrieve
    
.Parameter Refresh  
    Indicates whether the cmdlet refreshes the storage system information before retrieving the specified host storages

.Parameter RescanAllHba  
    Indicates whether to issue a request to rescan all virtual machine hosts bus adapters for new storage devices prior to retrieving the storage information

.Parameter RescanVmfs  
    Indicates whether to perform a re-scan for new virtual machine file systems 
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [string]$Id,
    [switch]$Refresh,
    [switch]$RescanAllHba,
    [switch]$RescanVmfs
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if([System.String]::IsNullOrWhiteSpace($Id) -eq $true){
        $Script:Output = Get-VmHostStorage -Server $Script:vmServer -VMHost $HostName -Refresh:$Refresh `
                            -RescanAllHba:$RescanAllHba -RescanVmfs:$RescanVmfs -ErrorAction Stop | Select-Object *   
    }
    else {
        $Script:Output = Get-VmHostStorage -Server $Script:vmServer -ID $Id -ErrorAction Stop | Select-Object *          
    }
    
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