#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new folder on a vCenter Server system

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
        [sr-en] Name for the new folder
        [sr-de] Ordnername 

    .Parameter LocationName
        [sr-en] Container object where you want to place the new folder
        [sr-de] Containerobjekt

    .Parameter LocationType
        [sr-en] Type of the container object (folder(VM), datacenter, or cluster) where you want to place the new folder
        [sr-de] Typ des Containerobjekts 
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$FolderName,
    [Parameter(Mandatory = $true)]
    [string]$LocationName,
    [Parameter(Mandatory = $true)]
    [ValidateSet("VM", "HostAndCluster", "Datacenter")]
    [string]$LocationType = "VM"
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:location = Get-Folder -Server $Script:vmServer -Name $LocationName -Type $LocationType -ErrorAction Stop
    
    if($null -eq $Script:location){
        throw "Location $($LocationName) not found"
    }
    $result = New-Folder -Server $Script:vmServer -Name $FolderName -Location $Script:location -Confirm:$False -ErrorAction Stop | Select-Object *        
        
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