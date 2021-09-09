#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Updates the specified host

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
        [sr-de] IP Adresse oder Name des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto um diese Aktion durchzuführen

    .Parameter HostName
        [sr-en] Name of the host you want to retrieve patches
        [sr-de] Hostname

    .Parameter HostCredential
        [sr-en] PSCredential object that contains credentials for authenticating with the host
        [sr-de] Benutzerkonto zur Hostauthentifizierung

    .Parameter HostUsername
        [sr-en] User name for authenticating with the host
        [sr-de] Benutzername zur Hostauthentifizierung

    .Parameter HostPassword
        [sr-en] Password for authenticating with the host
        [sr-de] Kennwort zur Hostauthentifizierung

    .Parameter WebPath
        [sr-en] Web location of the patches
        [sr-de] Webadresse der Patchs

    .Parameter HostPath
        [sr-en] File path on the ESX/ESXi host to the patches
        [sr-de] Pfad der Patchs auf dem ESX/ESXi Host

    .Parameter LocalPath
        [sr-en] Local file system path to the patches
        [sr-de] Pfad der Patchs
        
    .Parameter RunAsync
        [sr-en] Indicates that the command returns immediately without waiting for the task to complete
        [sr-de] Asynchrone Ausführung
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "HostPath")]
    [Parameter(Mandatory = $true,ParameterSetName = "WebPath")]
    [Parameter(Mandatory = $true,ParameterSetName = "LocalPath")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "HostPath")]
    [Parameter(Mandatory = $true,ParameterSetName = "WebPath")]
    [Parameter(Mandatory = $true,ParameterSetName = "LocalPath")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "HostPath")]
    [Parameter(Mandatory = $true,ParameterSetName = "WebPath")]
    [Parameter(Mandatory = $true,ParameterSetName = "LocalPath")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "HostPath")]
    [string]$HostPath,
    [Parameter(Mandatory = $true,ParameterSetName = "WebPath")]
    [string]$WebPath,
    [Parameter(Mandatory = $true,ParameterSetName = "LocalPath")]
    [string]$LocalPath,
    [Parameter(ParameterSetName = "LocalPath")]
    [pscredential]$HostCredential,
    [Parameter(ParameterSetName = "LocalPath")]
    [string]$HostUsername,
    [Parameter(ParameterSetName = "LocalPath")]
    [securestring]$HostPassword,
    [Parameter(ParameterSetName = "HostPath")]
    [Parameter(ParameterSetName = "WebPath")]
    [Parameter(ParameterSetName = "LocalPath")]
    [switch]$RunAsync
)

Import-Module VMware.VimAutomation.Core

try{  
    $Script:result = $null
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                           'Server' = $Script:vmServer
    }
    $vmHost = Get-VMHost @cmdArgs -Name $HostName

    $cmdArgs.Add('RunAsync', $null)
    $cmdArgs.Add('Confirm', $false)
    $cmdArgs.Add('VMHost', $vmHost)
    if($PSCmdlet.ParameterSetName -eq 'LocalPath'){
        if($PSBoundParameters.ContainsKey('HostCredential') -eq $true){
            $cmdArgs.Add('HostCredential', $HostCredential)
        }
        else{
            if($PSBoundParameters.ContainsKey('HostUsername') -eq $true){
                $cmdArgs.Add('HostUsername', $HostUsername)
            }
            if($PSBoundParameters.ContainsKey('HostPassword') -eq $true){
                $cmdArgs.Add('HostPassword', $HostPassword)
            }
        }
        $Script:result = Install-VMHostPatch @cmdArgs -LocalPath $LocalPath 
    }
    elseif($PSCmdlet.ParameterSetName -eq 'WebPath'){
        $Script:result = Install-VMHostPatch @cmdArgs -WebPath $WebPath        
    }
    else{
        $Script:result = Install-VMHostPatch @cmdArgs -HostPath $HostPath        
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
    }
    else{
        Write-Output $Script:result
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