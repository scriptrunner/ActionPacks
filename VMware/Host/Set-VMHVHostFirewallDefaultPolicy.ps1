#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Sets the default policy for the specified host firewall

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
    Specifies the name of the host whose firewall default policy you want to modify

.Parameter AllowOutgoing
    If the value of this parameter is $true, all outcoming connections are allowed

.Parameter AllowIncoming
    If the value of this parameter is $true, all incoming connections are allowed
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [bool]$AllowOutgoing = $true,
    [bool]$AllowIncoming = $true
)

Import-Module VMware.PowerCLI

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop

    $Script:defPolicy = Get-VMHostFirewallDefaultPolicy -Server $Script:vmServer -VMHost $vmHost -ErrorAction Stop
    $Script:Output = $Script:defPolicy | Select-Object *
    if($PSBoundParameters.ContainsKey('AllowIncoming') -eq $true){
        $Script:Output = Set-VMHostFirewallDefaultPolicy -Policy $Script:defPolicy -AllowIncoming $AllowIncoming -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('AllowOutgoing') -eq $true){
        $Script:Output = Set-VMHostFirewallDefaultPolicy -Policy $Script:defPolicy -AllowOutgoing $AllowOutgoing -Confirm:$false -ErrorAction Stop | Select-Object *
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