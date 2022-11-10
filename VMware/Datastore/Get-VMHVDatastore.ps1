#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Retrieves the datastores available on a vCenter Server system

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Datastore

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter Datastore
        [sr-en] Name of the datastore
        [sr-de] Name des Datastores

    .Parameter RefreshFirst
        [sr-en] Refreshes the storage system information and then retrieves the specified datastores
        [sr-de] Speichersysteminformationen aktualisieren

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$Datastore,
    [switch]$RefreshFirst,
    [ValidateSet('*','Name','State','CapacityGB','FreeSpaceGB','Datacenter')]
    [string[]]$Properties = @('Name','State','CapacityGB','FreeSpaceGB','Datacenter')
)

Import-Module VMware.VimAutomation.Core

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if([System.String]::IsNullOrWhiteSpace($Datastore) -eq $true){
        $Script:Output = Get-Datastore -Server $Script:vmServer -Refresh:$RefreshFirst -ErrorAction Stop | Select-Object $Properties
    }
    else {
        $Script:Output = Get-Datastore -Server $Script:vmServer -Refresh:$RefreshFirst -Name $Datastore -ErrorAction Stop | Select-Object $Properties   
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