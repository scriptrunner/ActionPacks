#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

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
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter ProfileName
        [sr-en] Host profile you want to apply

    .Parameter HostName
        [sr-en] Host to which you want to apply the virtual machine host profile
        [sr-de] Hostname

    .Parameter ClusterName
        [sr-en] Cluster to which you want to apply the virtual machine host profile
        [sr-de] Clustername

    .Parameter ApplyOnly
        [sr-en] Apply the host profile to the specified virtual machine host without associating it
        [sr-de] Anwenden des Hostprofils ohne es zuzuordnen

    .Parameter AssociateOnly
        [sr-en] Associate the host profile to the specified host or cluster without applying it
        [sr-de] Hostprofil zuordnen, ohne es anzuwenden
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

Import-Module VMware.VimAutomation.Core

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