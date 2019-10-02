#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Removes the specified folder

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Folder

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter FolderName
    Specifies the folder you want to remove

.Parameter DeletePermanently
    Indicates that you want to delete from the disk any virtual machines contained in the specified folder, and not only to remove them from the inventory
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [switch]$DeletePermanently
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:folder = Get-Folder -Server $Script:vmServer -Name $FolderName -ErrorAction Stop    
    if($null -eq $Script:folder){
        throw "Folder $($FolderName) not found"
    }
    Remove-Folder -Server $Script:vmServer -Folder $Script:folder -DeletePermanently:$DeletePermanently -Confirm:$false -ErrorAction Stop 

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Folder $($FolderName) successfully removed"
    }
    else{
        Write-Output "Folder $($FolderName) successfully removed"
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