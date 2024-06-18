#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

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
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter HostName
        [sr-en] Host whose networking configuration you want to modify
        [sr-de] Hostname

    .Parameter ConsoleGateway
        [sr-en] New console gateway
        [sr-de] Gateway Adresse

    .Parameter ConsoleGatewayDevice  
        [sr-en] New console gateway device
        [sr-de] Konsole Gateway
        
    .Parameter ConsoleV6Gateway  
        [sr-en] Console V6 gateway address
        [sr-de] V6 Gateway

    .Parameter ConsoleV6GatewayDevice  
        [sr-en] Console V6 gateway device
        [sr-de] V6 Gateway

    .Parameter DnsAddress  
        [sr-en] New DNS address
        [sr-de] Neue DNS Adresse

    .Parameter DomainName 
        [sr-en] New domain name
        [sr-de] Neuer Domänenname

    .Parameter HostName 
        [sr-en] New host name
        [sr-de] Neuer Hostname

    .Parameter IPv6Enabled
        [sr-en] IPv6 configuration is enabled 
        [sr-de] IPv6 aktivieren

    .Parameter SearchDomain
        [sr-en] New search domain
        [sr-de] Neue Suchdomäne
        
    .Parameter VMKernelGateway
        [sr-en] New kernel gateway
        [sr-de] Neuer Kernel Gateway

    .Parameter VMKernelGatewayDevice
        [sr-en] New kernel gateway device
        [sr-de] Kernel Gateway

    .Parameter VMKernelV6Gateway
        [sr-en] VMKernel V6 gateway address 
        [sr-de] V6 Kernel Gateway Adresse

    .Parameter VMKernelV6GatewayDevice
        [sr-en] VMKernel V6 gateway device   
        [sr-de] V6 Kernel Gateway
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

Import-Module VMware.VimAutomation.Core

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