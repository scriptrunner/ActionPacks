#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Configures hosts firmware settings

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
    Specifies the name of the host for which you want to modify the firmware informations
    
.Parameter HostCredential
    Specifies the credential object you want to use for authenticating with the host when uploading a firmware configuration bundle

.Parameter SourcePath
    Specifies the path to the host configuration backup bundle you want to restore
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true,ParameterSetName = "Restore")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true,ParameterSetName = "Restore")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Reset")]
    [Parameter(Mandatory = $true,ParameterSetName = "Restore")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Restore")]
    [pscredential]$HostCredential,
    [Parameter(ParameterSetName = "Restore")]
    [string]$SourcePath
)

Import-Module VMware.PowerCLI

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $Script:vmHost = Get-VMHost -Server $Script:vmServer -Name $Script:HostName -ErrorAction Stop
    Set-VMHost -VMHost $Script:vmHost -State 'Maintenance'

    if($PSCmdlet.ParameterSetName  -eq "Reset"){
        $null = Set-VMHostFirmware -Server $Script:vmServer -VMHost $Script:vmHost -ResetToDefaults -Confirm:$false -ErrorAction Stop
    }
    else {
        $null = Set-VMHostFirmware -Server $Script:vmServer -VMHost $Script:vmHost -Restore -HostCredential $HostCredential -SourcePath $SourcePath -Force:$true -Confirm:$false -ErrorAction Stop
    }
    $result = Get-VMHostFirmware -Server $Script:vmServer -VMHost $Script:vmHost -ErrorAction Stop | Select-Object *

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