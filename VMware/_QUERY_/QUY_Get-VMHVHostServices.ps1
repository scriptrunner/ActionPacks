#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves information about a host services

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

.Parameter HostName
    Specifies the host for which you want to retrieve the available services

.Parameter GetKeys
    Retrieve the keys otherwise the labels of the available services
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [bool]$GetKeys
)

Import-Module VMware.PowerCLI

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $services = Get-VMHostService -Server $Script:vmServer -VMHost $HostName -Refresh -ErrorAction Stop | Select-Object Key,Label | Sort-Object Label
    
    foreach($item in $services){
        if($SRXEnv) {
            if($GetKeys -eq $true){
                $null = $SRXEnv.ResultList.Add($item.Key)
            }
            else{
                $null = $SRXEnv.ResultList.Add($item.Label)
            }
            $null = $SRXEnv.ResultList2.Add($item.Label) # Display
        }
        else{
            Write-Output $item.Label
        }
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