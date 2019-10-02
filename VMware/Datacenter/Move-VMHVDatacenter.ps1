#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Moves a vCenter Server datacenter from one location to another

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Datacenter

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter Datacenter
    Specifies the name of the datacenter you want to move

.Parameter DestinationFolder
    Specifies the folder where you want to move the datacenter
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Datacenter,
    [Parameter(Mandatory = $true)]
    [string]$DestinationFolder
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:dCenter = Get-Datacenter -Server $Script:vmServer -Name $Datacenter -ErrorAction Stop
    $Script:folder = Get-Folder -Server $Script:vmServer -Name $DestinationFolder -Type Datacenter -ErrorAction Stop
    $null = Move-Datacenter -Server $Script:vmServer -Datacenter $Script:dCenter -Destination $Script:folder -Confirm:$false -ErrorAction Stop
    $Script:dCenter = Get-Datacenter -Server $Script:vmServer -Name $Datacenter -ErrorAction Stop

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:dCenter | Select-Object *
    }
    else{
        Write-Output $Script:dCenter | Select-Object *
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