#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Retrieves the virtual switches

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VirtualSwitch

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter Id
        [sr-en] ID of the virtual machine
        [sr-de] ID der VM

    .Parameter Name
        [sr-en] Name of the virtual machine
        [sr-de] Name der VM

    .Parameter Datacenter
        [sr-en] Filters the virtual switch connected to hosts in the specified datacenter
        [sr-de] Virtual Switches dieses Datacenter

    .Parameter VM
        [sr-en] Virtual machine whose virtual switch you want to retrieve
        [sr-de] VM

    .Parameter Standard
        [sr-en] Retrieve only VirtualSwitch objects
        [sr-de] Nur VirtualSwitch-Objekte
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byDatacenter")]
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byDatacenter")]
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$ID,
    [Parameter(Mandatory = $true,ParameterSetName = "byDatacenter")]
    [string]$Datacenter,
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [string]$VM,
    [Parameter(ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatacenter")]
    [Parameter(ParameterSetName = "byVM")]
    [switch]$Standard
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'Standard' = $Standard
                            }                            

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $cmdArgs.Add('ID', $ID)        
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byName"){
        if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
            $cmdArgs.Add('Name', $Name)
        }        
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byDatacenter"){
        $cmdArgs.Add('Datacenter', $Datacenter)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byVM"){
        $cmdArgs.Add('VM', $VM)
    }
    $result = Get-VirtualSwitch @cmdArgs | Select-Object *

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