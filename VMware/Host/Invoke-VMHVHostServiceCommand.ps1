#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Invokes a command for the specified host services. 
        The acceptable commands are: Start, Stop, Restart

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
        [sr-en] Host for which you want to invoke the command
        [sr-de] Hostname

    .Parameter ServiceKey
        [sr-en] Key of the service you want to invoke the command
        [sr-de] Id des Dienstes

    .Parameter ServiceLabel
        [sr-en] Label of the service you want to invoke the command
        [sr-de] Bezeichnung des Dienstes

    .Parameter Command
        [sr-en] Command that executed on the host services
        [sr-de] Auszuführender Befehl
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [string]$ServiceKey,
    [string]$ServiceLabel,
    [ValidateSet("Start", "Stop","Restart")]
    [string]$Command = "Restart"
)

Import-Module VMware.VimAutomation.Core

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:Output = @()
    $Script:services = Get-VMHostService -Server $Script:vmServer -VMHost $HostName -Refresh:$Refresh -ErrorAction Stop
    
    if([System.String]::IsNullOrWhiteSpace($ServiceKey) -eq $false){
        $Script:Output += $Script:services  | Where-Object {$_.Key -like $ServiceKey}
    }
    if([System.String]::IsNullOrWhiteSpace($ServiceLabel) -eq $false){
        $Script:Output += $Script:services  | Where-Object { $_.Label -like $ServiceLabel}  
    }
    if($Command -eq "Start"){
        $Script:Output = $Script:Output | Start-VMHostService -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    elseif($Command -eq "Stop"){
        $Script:Output = $Script:Output | Stop-VMHostService -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    elseif($Command -eq "Restart"){
        $Script:Output = $Script:Output | Restart-VMHostService -Confirm:$false -ErrorAction Stop | Select-Object *    
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