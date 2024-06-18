#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

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
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Folder

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter FolderName
        [sr-en] Folder you want to remove
        [sr-de] Ordnername

    .Parameter DeletePermanently
        [sr-en] Delete from the disk any virtual machines contained in the specified folder, and not only to remove them from the inventory
        [sr-de] Ordner wird nicht nur aus dem Inventar, sondern auch aus dem Datenspeicher gelöscht
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

Import-Module VMware.VimAutomation.Core

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