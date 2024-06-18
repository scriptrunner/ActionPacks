#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Tests hosts for profile compliance

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

    .Parameter ProfileName
        [sr-en] Host profile against which to test the specified host for compliance with the host to which it is associated
        [sr-de] Hostprofil

    .Parameter HostName
        [sr-en] Host you want to test for profile compliance with the profile associated with it
        [sr-de] Hostname

    .Parameter UseCache
        [sr-en] Indicates that you want the vCenter Server to return cached information
        [sr-de] Zwischengespeicherte vCenter Server-Informationen zurückgeben
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [Parameter(Mandatory = $true,ParameterSetName = "Profile")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [Parameter(Mandatory = $true,ParameterSetName = "Profile")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Profile")]
    [string]$ProfileName,
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Host")]
    [Parameter(ParameterSetName = "Profile")]
    [switch]$UseCache
)

Import-Module VMware.VimAutomation.Core

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "Profile"){
        $profile = Get-VMHostProfile -Server $Script:vmServer -Name $ProfileName -ErrorAction Stop
        $Script:Output = Test-VMHostProfileCompliance -Server $Script:vmServer -Profile $profile -UseCache:$UseCache -ErrorAction Stop | Select-Object *
    }
    else{
        $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
        $Script:Output = Test-VMHostProfileCompliance -Server $Script:vmServer -VMHost $vmHost -UseCache:$UseCache -ErrorAction Stop | Select-Object *
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