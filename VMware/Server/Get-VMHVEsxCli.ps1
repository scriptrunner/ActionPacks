#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Exposes the ESXCLI functionality

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Server

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter HostName
        [sr-en] Name of the host on which you want to expose the ESXCLI functionality, is the parameter empty from all hosts retrieve the infos
        [sr-de] Host der ESXCli Funktionen
        
    .Parameter V2
        [sr-en] If specified, returns an EsxCli object version 2 (V2), otherwise an EsxCli object version 1 (V1) is returned
        [sr-de] EsxCli Version 2 (V2) Objekte
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [switch]$V2
)

Import-Module VMware.VimAutomation.Core

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if([System.String]::IsNullOrWhiteSpace($HostName) -eq $true){
        $Script:Output = Get-EsxCli -Server $Script:vmServer -V2:$V2 -ErrorAction Stop | Select-Object *
    }
    else{
        $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
        $Script:Output = Get-EsxCli -Server $Script:vmServer -V2:$V2 -VMHost $vmHost -ErrorAction Stop | Select-Object *
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