#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Retrieves entries from vSphere logs

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
        [sr-en] Name of the host you want to retrieve logs
        [sr-de] Hostname

    .Parameter LogFileKey
        [sr-en] Key identifier of the log file you want to retrieve. 
        If the parameter is empty, the first key of the log types is used
        [sr-de] Id der Logdatei

    .Parameter StartLineNumber
        [sr-en] Start line number for reading from the logs
        [sr-de] Startzeile des Logs

    .Parameter LineNumbers
        [sr-en] Number of the lines you want to retrieve from the logs
        [sr-de] Anzahl der Zeilen

    .Parameter Bundle
        [sr-en] Retrieve a diagnostic bundle of logs from vCenter Server
        [sr-de] Mehrere Diagnose-Logs 

    .Parameter DestinationPath
        [sr-en] Local file path where you want to save the log bundle
        [sr-de] Dateiname der Logdatei
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [string]$LogFileKey,
    [int32]$StartLineNumber = 1,
    [int32]$LineNumbers = 20,
    [switch]$Bundle,
    [string]$DestinationPath
)

Import-Module VMware.VimAutomation.Core

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $Script:vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop

    if($Bundle -eq $true){
        $Script:Output = Get-Log -Server $Script:vmServer -VMHost $Script:vmHost -Bundle -DestinationPath $DestinationPath `
                            -ErrorAction Stop
    }
    else {
        if([System.String]::IsNullOrWhiteSpace($LogFileKey) -eq $true){
            $LogFileKey = Get-LogType -Server $Script:vmServer -VMHost $Script:vmHost -ErrorAction Stop | Select-Object -First 1 -ExpandProperty Key
        }
        $Script:Output = Get-Log -Server $Script:vmServer -VMHost $Script:vmHost -Key $LogFileKey -StartLineNum $StartLineNumber `
                            -NumLines $LineNumbers -ErrorAction Stop | Select-Object -ExpandProperty Entries
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