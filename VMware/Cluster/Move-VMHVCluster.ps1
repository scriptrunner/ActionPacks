#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Moves a vCenter Server cluster from one location to another

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Cluster

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter ClusterID
    Specifies the ID of the cluster you want to move to another location

.Parameter ClusterName
    Specifies the name of the cluster you want to move to another location

.Parameter DestinationName
    Specifies the destination where you want to move the cluster
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
    [string]$ClusterID,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$ClusterName,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [switch]$DestinationName
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @('Name','Id','HATotalSlots','HAUsedSlots','HAEnabled','HASlotMemoryGB','HASlotNumVCpus')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:cluster = Get-Cluster -Server $Script:vmServer -Id $ClusterID -ErrorAction Stop
    }
    else{
        $Script:cluster = Get-Cluster -Server $Script:vmServer -Name $ClusterName -ErrorAction Stop
    } 
    $Script:destination = Get-Folder -Server $Script:vmServer -Name $DestinationName -ErrorAction Stop
    if($null -eq $Script:destination){
        throw "Destination $($DestinationName) not found"
    }
    $null = Move-Cluster -Cluster $Script:cluster -Destination -$Script:destination -Server $Script:vmServer -Confirm:$false -ErrorAction Stop
    $Script:Output = Get-Cluster -Server $Script:vmServer -Name $Script:cluster.Name -ErrorAction Stop | Select-Object $Properties

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