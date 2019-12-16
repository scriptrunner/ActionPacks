#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Updates the specified virtual network

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
    Specifies the host whose networking configuration you want to modify

.Parameter ConsoleGateway
    Specifies a new console gateway

.Parameter ConsoleGatewayDevice  
    Specifies a new console gateway device
    
.Parameter ConsoleV6Gateway  
    Specifies a console V6 gateway address

.Parameter ConsoleV6GatewayDevice  
    Specifies a console V6 gateway device

.Parameter DnsAddress  
    Specifies a new DNS address

.Parameter DomainName 
    Specifies a new domain name

.Parameter HostName 
    Specifies a new host name

.Parameter IPv6Enabled
    Indicates that IPv6 configuration is enabled 

.Parameter SearchDomain
    Specifies a new search domain
    
.Parameter VMKernelGateway
    Specifies a new kernel gateway

.Parameter VMKernelGatewayDevice
    Specifies a new kernel gateway device

.Parameter VMKernelV6Gateway
    Specifies a VMKernel V6 gateway address 

.Parameter VMKernelV6GatewayDevice
    Specifies a VMKernel V6 gateway device     
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [string]$ConsoleGateway,
    [string]$ConsoleGatewayDevice,
    [string]$ConsoleV6Gateway,
    [string]$ConsoleV6GatewayDevice,
    [string]$DnsAddress,
    [string]$DomainName,
    [bool]$IPv6Enabled,
    [string]$SearchDomain,
    [string]$VMKernelGateway,
    [string]$VMKernelGatewayDevice,
    [string]$VMKernelV6Gateway,
    [string]$VMKernelV6GatewayDevice
    
)

Import-Module VMware.PowerCLI

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop

    $netInfo = Get-VMHostNetwork -Server $Script:vmServer -VMHost $vmHost -ErrorAction Stop
    $Script:Output = $Script:netInfo | Select-Object *

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Network' = $netInfo
                            'Confirm' = $false
                            }                                
    
    if($PSBoundParameters.ContainsKey('ConsoleGateway') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -ConsoleGateway $ConsoleGateway | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('ConsoleGatewayDevice') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -ConsoleGatewayDevice $ConsoleGatewayDevice | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('ConsoleV6Gateway') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -ConsoleV6Gateway $ConsoleV6Gateway | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('ConsoleV6GatewayDevice') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -ConsoleV6GatewayDevice $ConsoleV6GatewayDevice | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('DnsAddress') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -DnsAddress $DnsAddress | Select-Object *
    }    
    if($PSBoundParameters.ContainsKey('IPv6Enabled') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -IPv6Enabled $IPv6Enabled | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('VMKernelGateway') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -VMKernelGateway $VMKernelGateway | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('VMKernelGatewayDevice') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -VMKernelGatewayDevice $VMKernelGatewayDevice | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('VMKernelV6Gateway') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -VMKernelV6Gateway $VMKernelV6Gateway | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('VMKernelV6GatewayDevice') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -VMKernelV6GatewayDevice $VMKernelV6GatewayDevice | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('DomainName') -eq $true){
        $Script:Output = Set-VMHostNetwork @cmdArgs -DomainName $DomainName | Select-Object *
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