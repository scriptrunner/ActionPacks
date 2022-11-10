#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Modifies the specified virtual machine snapshot

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VMs

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP-Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Anmeldedaten für die Authentifizierung beim Server

    .Parameter VMId
        [sr-en] ID of the virtual machine
        [sr-de] ID der VM

    .Parameter VMName
        [sr-en] Name of the virtual machine
        [sr-de] Name der VM

    .Parameter SnapShotName
        [sr-en] Name of the snapshot
        [sr-de] Snapshot-Name

    .Parameter NewName
        [sr-en] New name of the new snapshot
        [sr-de] Neuer Name des neuen Snapshots

    .Parameter NewDescription
        [sr-en] New description of the new snapshot
        [sr-de] Neue Beschreibung des neuen Snapshots
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$VMId,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$SnapShotName, 
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewDescription
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('Name','Created','PowerState','SizeGB','Description','IsCurrent','Id')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }
    $Script:snapshot = Get-Snapshot -Server $Script:vmServer -VM $Script:machine -Name $SnapShotName -ErrorAction Stop
    $Script:Output = $Script:snapshot
    if($PSBoundParameters.ContainsKey('NewName') -eq $true){
        $Script:Output = Set-Snapshot -Snapshot $Script:snapshot -Name $NewName -Confirm:$false `
                        -ErrorAction Stop  | Select-Object $Properties
    }
    if($PSBoundParameters.ContainsKey('NewDescription') -eq $true){
        $Script:Output = Set-Snapshot -Snapshot $Script:snapshot -Description $NewDescription -Confirm:$false `
                        -ErrorAction Stop  | Select-Object $Properties
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