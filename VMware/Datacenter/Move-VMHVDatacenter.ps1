#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Moves a vCenter Server datacenter from one location to another

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Datacenter

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter Datacenter
        [sr-en] Name of the datacenter you want to move
        [sr-de] Datacenter

    .Parameter DestinationFolder
        [sr-en] Folder where you want to move the datacenter
        [sr-de] Ordnername
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Datacenter,
    [Parameter(Mandatory = $true)]
    [string]$DestinationFolder
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:dCenter = Get-Datacenter -Server $Script:vmServer -Name $Datacenter -ErrorAction Stop
    $Script:folder = Get-Folder -Server $Script:vmServer -Name $DestinationFolder -Type Datacenter -ErrorAction Stop
    $null = Move-Datacenter -Server $Script:vmServer -Datacenter $Script:dCenter -Destination $Script:folder -Confirm:$false -ErrorAction Stop
    $Script:dCenter = Get-Datacenter -Server $Script:vmServer -Name $Datacenter -ErrorAction Stop

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:dCenter | Select-Object *
    }
    else{
        Write-Output $Script:dCenter | Select-Object *
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