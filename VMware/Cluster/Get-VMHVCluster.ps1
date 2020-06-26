#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the clusters available on a vCenter Server system

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
    Specifies the ID of the cluster you want to retrieve

.Parameter ClusterName
    Specifies the name of the cluster you want to retrieve, is the parameter empty all hosts retrieved

.Parameter VM
    Specifies the name of the virtual machine to filter the cluster that contain at least them

.Parameter NoRecursion
    Indicates that you want to disable the recursive behavior of the command

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Id. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$ClusterID,
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [string]$VM,
    [Parameter(ParameterSetName = "byName")]
    [string]$ClusterName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byVM")]
    [switch]$NoRecursion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byVM")]
    [ValidateSet('*','Name','Id','HATotalSlots','HAUsedSlots','HAEnabled','HASlotMemoryGB','HASlotNumVCpus')]
    [string[]]$Properties = @('Name','Id','HATotalSlots','HAUsedSlots','HAEnabled','HASlotMemoryGB','HASlotNumVCpus')
)

Import-Module VMware.PowerCLI

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:Output = Get-Cluster -Server $Script:vmServer -Id $ClusterID -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object $Properties
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byVM"){
        $Script:Output = Get-Cluster -Server $Script:vmServer -VM $VM  -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object $Properties
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($ClusterName) -eq $true){
            $Script:Output = Get-Cluster -Server $Script:vmServer -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object $Properties
        }
        else{
            $Script:Output = Get-Cluster -Server $Script:vmServer -Name $ClusterName -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object $Properties
        }        
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