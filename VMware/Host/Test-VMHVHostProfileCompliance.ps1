#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Tests hosts for profile compliance

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
    Specifies a host profile against which to test the specified host for compliance with the host to which it is associated

.Parameter HostName
    Specifies the host you want to test for profile compliance with the profile associated with it

.Parameter UseCache
    Indicates that you want the vCenter Server to return cached information
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [Parameter(Mandatory = $true,ParameterSetName = "Profile")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [Parameter(Mandatory = $true,ParameterSetName = "Profile")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Profile")]
    [string]$ProfileName,
    [Parameter(Mandatory = $true,ParameterSetName = "Host")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Host")]
    [Parameter(ParameterSetName = "Profile")]
    [switch]$UseCache
)

Import-Module VMware.PowerCLI

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "Profile"){
        $profile = Get-VMHostProfile -Server $Script:vmServer -Name $ProfileName -ErrorAction Stop
        $Script:Output = Test-VMHostProfileCompliance -Server $Script:vmServer -Profile $profile -UseCache:$UseCache -ErrorAction Stop | Select-Object *
    }
    else{
        $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
        $Script:Output = Test-VMHostProfileCompliance -Server $Script:vmServer -VMHost $vmHost -UseCache:$UseCache -ErrorAction Stop | Select-Object *
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