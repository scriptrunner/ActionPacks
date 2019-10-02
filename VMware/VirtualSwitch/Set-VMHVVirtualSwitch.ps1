#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies the properties of the specified virtual switch 

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VirtualSwitch

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter Name
    Specifies the name of the virtual switch you want to modify

.Parameter PortNumber
    Specifies the VirtualSwitch port number

.Parameter Mtu
    Specifies the maximum transmission unit (MTU) associated with the specified virtual switch (in bytes)
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [int32]$PortNumber,
    [int32]$Mtu
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:switch = Get-VirtualSwitch -Server $Script:vmServer -Name $Name -ErrorAction Stop
    if($PortNumber -gt 0){
        $Script:switch = Set-VirtualSwitch -VirtualSwitch $Script:switch -Server $Script:vmServer -NumPorts $PortNumber -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    if($Mtu -gt 0){
        $Script:switch = Set-VirtualSwitch -VirtualSwitch $Script:switch -Server $Script:vmServer -Mtu $Mtu -Confirm:$false -ErrorAction Stop | Select-Object *
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:switch 
    }
    else{
        Write-Output $Script:switch
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