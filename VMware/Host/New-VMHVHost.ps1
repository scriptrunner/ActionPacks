#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new host

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

.Parameter Name
    Specifies a name for the new host

.Parameter LocationName
    Specifies a datacenter name or folder name where you want to place the host

.Parameter Port
    Specifies the port on the host you want to use for the connection

.Parameter HostCredential
    Specifies a PSCredential object that contains credentials for authenticating with the virtual machine host
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$LocationName,
    [int32]$Port,
    [pscredential]$HostCredential
)

Import-Module VMware.PowerCLI

try{
    [string[]]$Properties = @('Name','Id','PowerState','ConnectionState','IsStandalone','LicenseKey')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $location = Get-Folder -Server $Script:vmServer -Name $LocationName -ErrorAction Stop
    if($null -eq $location){
        throw "Location $($LocationName) not found"
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'Name' = $Name
                            'Location' = $location
                            'Force' = $null
                            'Confirm' = $false
                            }                            

    if($null -ne $HostCredential){
        $cmdArgs.Add('Credential', $HostCredential)
    }
    if($Port -gt 0){
        $cmdArgs.Add('Port', $Port)
    }
    $null = Add-VMHost @cmdArgs
    $result = Get-VMHost -Server $Script:vmServer -Name $Name -NoRecursion:$true -ErrorAction Stop | Select-Object $Properties

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