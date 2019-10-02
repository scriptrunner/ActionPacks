#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Applies a host profile to the specified host or cluster

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter ProfileName
    Specifies the host profile you want to apply

.Parameter HostName
    Specifies host to which you want to apply the virtual machine host profile

.Parameter ClusterName
    Specifies cluster to which you want to apply the virtual machine host profile

.Parameter ApplyOnly
    Indicates whether to apply the host profile to the specified virtual machine host without associating it

.Parameter AssociateOnly
    Indicates whether to associate the host profile to the specified host or cluster without applying it
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [Parameter(Mandatory = $true,ParameterSetName = "Cluster")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [Parameter(Mandatory = $true,ParameterSetName = "Cluster")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [Parameter(Mandatory = $true,ParameterSetName = "Cluster")]
    [string]$ProfileName,
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Cluster")]
    [string]$ClusterName,    
    [Parameter(ParameterSetName = "Host")]
    [Parameter(ParameterSetName = "Cluster")]
    [switch]$ApplyOnly,
    [Parameter(ParameterSetName = "Host")]
    [Parameter(ParameterSetName = "Cluster")]
    [switch]$AssociateOnly
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $profile = Get-VMHostProfile -Name $ProfileName -Server $Script:vmServer -ErrorAction Stop
    if($PSCmdlet.ParameterSetName  -eq "Host"){
        $Script:entity = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    }
    else{
        $Script:entity = Get-Cluster -Server $Script:vmServer -Name $ClusterName -ErrorAction Stop
    }
    $null = Invoke-VMHostProfile -Entity $Script:entity -Profile $profile -AssociateOnly:$AssociateOnly `
                        -ApplyOnly:$ApplyOnly -Server $Script:vmServer -Confirm:$false -ErrorAction Stop
    
    if($PSCmdlet.ParameterSetName  -eq "Host"){
        $Script:Output = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop | Select-Object *
    }
    else{
        $Script:Output = Get-Cluster -Server $Script:vmServer -Name $ClusterName -ErrorAction Stop | Select-Object *
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