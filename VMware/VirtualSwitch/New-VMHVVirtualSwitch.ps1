#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new virtual switch

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VirtualSwitch

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter Name
        [sr-en] Name for the new virtual switch
        [sr-de] Name der neuen Virtual Switch

    .Parameter VMHost
        [sr-en] Host on which you want to create the new virtual switch
        [sr-de] Host der neuen Virtual Switch

    .Parameter PortNumber
        [sr-en] Virtual switch port number
        [sr-de] Port-Nummer der neuen Virtual Switch
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$VMHost,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [int32]$PortNumber
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if($PortNumber -gt 0){
        $Script:Output = New-VirtualSwitch -Server $Script:vmServer -Name $Name -VMHost $VMHost -NumPorts $PortNumber -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    else{
        $Script:Output = New-VirtualSwitch -Server $Script:vmServer -Name $Name -VMHost $VMHost -Confirm:$false -ErrorAction Stop | Select-Object *
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