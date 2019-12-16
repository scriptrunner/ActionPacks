#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the host network adapters on a vCenter Server system

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
    Specifies the name of the host whose network adapters you want to retrieve

.Parameter Console
    Indicates that you want to retrieve only service console virtual network adapters

.Parameter Physical
    Indicates that you want to retrieve only physical network adapters

.Parameter VMKernel
    Indicates that you want to retrieve only VMKernel virtual network adapters

.Parameter AdapterName
    Specifies the name of the host network adapter you want to retrieve

.Parameter PortGroupName
    Specifies the name of the port group to which network adapters that you want to retrieve are connected
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [switch]$Console,
    [switch]$Physical,
    [switch]$VMKernel,
    [string]$AdapterName,
    [string]$PortGroupName
)

Import-Module VMware.PowerCLI

try{
    if([System.String]::IsNullOrWhiteSpace($HostName) -eq $true){
        $HostName = "*"
    }    
    if([System.String]::IsNullOrWhiteSpace($AdapterName) -eq $true){
        $AdapterName = "*"
    }    
    if([System.String]::IsNullOrWhiteSpace($PortGroupName) -eq $true){
        $PortGroupName = "*"
    }    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $result = Get-VMHostNetworkAdapter -Server $Script:vmServer -Console:$Console -Physical:$Physical -VMKernel:$VMKernel `
                     -Name $AdapterName -PortGroup $PortGroupName -VMHost $HostName -ErrorAction Stop | Select-Object *

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