#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies the specified host profile

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
    Specifies the name of the host profile you want to modify

.Parameter NewName
    Specifies a new name for the host profile

.Parameter Description
    Specifies a new description for the host profile
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$ProfileName,    
    [switch]$Description,   
    [string]$NewName
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:profile = Get-VMHostProfile -Server $Script:vmServer -Name $ProfileName -ErrorAction Stop

    if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
        $null = Set-VMHostProfile -Profile $Script:profile -Server $Script:vmServer -Description $Description -Confirm:$false -ErrorAction Stop
    }
    if([System.String]::IsNullOrWhiteSpace($NewName) -eq $false){
        $null = Set-VMHostProfile -Profile $Script:profile -Server $Script:vmServer -Name $NewName -Confirm:$false -ErrorAction Stop
    }

    $result = Get-VMHostProfile -Server $Script:vmServer -Name $ProfileName -ErrorAction Stop | Select-Object *
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