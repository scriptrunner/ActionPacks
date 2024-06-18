#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new host

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

    .Parameter Name
        [sr-en] Name for the new host
        [sr-de] Hostname

    .Parameter LocationName
        [sr-en] Datacenter name or folder name where you want to place the host
        [sr-de] Ziel-Datacenter/Ordner 

    .Parameter Port
        [sr-en] Port on the host you want to use for the connection
        [sr-de] Port

    .Parameter HostCredential
        [sr-en] PSCredential object that contains credentials for authenticating with the virtual machine host
        [sr-de] Host Benutzerkonto
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$LocationName,
    [int32]$Port,
    [pscredential]$HostCredential
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('Name','Id','PowerState','ConnectionState','IsStandalone','LicenseKey')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $location = Get-Folder -Server $Script:vmServer -Name $LocationName -ErrorAction Stop
    if($null -eq $location){
        throw "Location $($LocationName) not found"
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'Name' = $Name
                            'Location' = $location
                            'Force' = $null
                            'Confirm' = $false
                            }                            

    if($null -ne $HostCredential){
        $cmdArgs.Add('Credential', $HostCredential)
    }
    if($Port -gt 0){
        $cmdArgs.Add('Port', $Port)
    }
    $null = Add-VMHost @cmdArgs
    $result = Get-VMHost -Server $Script:vmServer -Name $Name -NoRecursion:$true -ErrorAction Stop | Select-Object $Properties

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