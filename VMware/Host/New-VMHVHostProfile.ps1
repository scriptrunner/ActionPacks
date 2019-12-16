#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new host profile based on a reference host

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

.Parameter ProfileName
    Specifies a name for the new host profile

.Parameter HostName
    Specifies the name of the reference host, on which the new virtual machine host profile is based

.Parameter CompatibilityMode
    If you are connected to a vCenter Server/ESX 5.0 or later, use this parameter to indicate that you want 
    new profile to be compatible with hosts running ESX/vCenter Server versions earlier than 5.0 

.Parameter Description
    Provides a description for the new host profile
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$ProfileName,
    [Parameter(Mandatory = $true)]
    [string]$HostName,    
    [switch]$CompatibilityMode,
    [string]$Description
)

Import-Module VMware.PowerCLI

try{  
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $true){
        $Description = " "
    }  
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    
    $null = New-VMHostProfile -Server $Script:vmServer -Name $ProfileName -ReferenceHost $vmHost `
                -CompatibilityMode:$CompatibilityMode -Description $Description -ErrorAction Stop

    $result = Get-VMHostProfile -Server $Script:vmServer -Name $ProfileName -ErrorAction Stop | Select-Object *
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